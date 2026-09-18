"""
One-time export step: Steinmetz et al. (2019) mouse Neuropixels dataset.

WHY PYTHON, HERE ONLY: the Neuromatch Academy (NMA)-prepared version of this
dataset ships as three `.npz` files, each containing a NumPy *object* array of
per-session Python dicts (spike counts, trial variables, brain-region labels,
etc). This is not a format R can read directly -- unlike every other dataset
in this repo, the raw file itself requires Python's numpy/pickle machinery to
open at all. This script is the one-time, one-directional bridge: it flattens
each session's dict into a single tidy CSV, after which the rest of the
pipeline (prepare_steinmetz.R) is ordinary tidyverse R, same as everything
else here.

Source: Steinmetz, N.A., Zatka-Haas, P., Carandini, M. & Harris, K.D. (2019).
Distributed coding of choice, action, and engagement across the mouse brain.
Nature, 576, 266-273. https://doi.org/10.1038/s41586-019-1787-x
Raw data (CC-BY-4.0): https://doi.org/10.6084/m9.figshare.9598406
This script uses the smaller, NMA-prepared, trial-binned subset instead of the
full raw archive, via the download URLs NMA's own materials use (credited
below) -- much more tractable for a course than the full ~8GB archive.

Run this once, from the repository root:
    python data-raw/python_prep/export_steinmetz_trials.py
Requires: numpy, pandas, requests (pip install numpy pandas requests)
Writes: data-raw/python_prep/steinmetz_trials_raw.csv
        data-raw/python_prep/steinmetz_sessions_raw.csv
(prepare_steinmetz.R picks these up from there -- nothing further in Python.)

Author: JMG
Date: 2026-09-16 (edit to reflect actual run date)
Credit: download/load approach adapted from Neuromatch Academy's own
course materials (NeuromatchAcademy/course-content, projects/neurons),
which in turn credit Steinmetz et al. for sharing the data.
"""

import os
import numpy as np
import pandas as pd
import requests

RAW_DIR = os.path.join("data-raw", "python_prep")
os.makedirs(RAW_DIR, exist_ok=True)

FNAMES = [os.path.join(RAW_DIR, f"steinmetz_part{j}.npz") for j in range(3)]
URLS = [
    "https://osf.io/agvxh/download",
    "https://osf.io/uv3mw/download",
    "https://osf.io/ehmw2/download",
]


def download_parts():
    """Download the three NMA-prepared Steinmetz .npz parts, if not already present."""
    for fname, url in zip(FNAMES, URLS):
        if os.path.isfile(fname):
            continue
        print(f"Downloading {url} -> {fname}")
        r = requests.get(url, timeout=120)
        r.raise_for_status()
        with open(fname, "wb") as fid:
            fid.write(r.content)


def load_all_sessions():
    """Load and concatenate all three parts into one array of per-session dicts."""
    alldat = np.array([])
    for fname in FNAMES:
        part = np.load(fname, allow_pickle=True)["dat"]
        alldat = np.hstack((alldat, part))
    return alldat


def flatten_to_trials(alldat):
    """
    Flatten each session's dict into one row per trial (behavioral summary
    only -- NOT the full neuron x trial x time spike tensor, which is a
    different, much larger export most course uses won't need; see the
    'extra data files' note in the NMA materials if that's ever wanted).
    """
    trial_rows = []
    session_rows = []
    region_rows = []
    for session_id, dat in enumerate(alldat):
        n_trials = len(dat["contrast_left"])
        spks = dat["spks"]  # neurons x trials x time_bins
        total_spikes_per_neuron_trial = spks.sum(axis=2)  # neurons x trials
        mean_spike_count = total_spikes_per_neuron_trial.mean(axis=0)  # length n_trials

        brain_area = np.array(dat["brain_area"])
        regions = sorted(set(brain_area))

        for t in range(n_trials):
            trial_rows.append({
                "session_id": session_id,
                "mouse_name": dat["mouse_name"],
                "trial": t,
                "contrast_left": dat["contrast_left"][t],
                "contrast_right": dat["contrast_right"][t],
                "response": dat["response"][t],       # -1, 0, 1
                "feedback_type": dat["feedback_type"][t],  # 1 = reward, -1 = no reward
                "response_time": float(dat["response_time"][t]),
                "mean_spike_count": float(mean_spike_count[t]),
                "n_neurons": spks.shape[0],
            })

            # one row per trial, one column per brain region -- this is the
            # wide, multi-feature matrix the PCA week actually wants.
            region_row = {"session_id": session_id, "trial": t}
            for region in regions:
                region_mask = brain_area == region
                region_row[region] = float(
                    total_spikes_per_neuron_trial[region_mask, t].mean()
                )
            region_rows.append(region_row)

        session_rows.append({
            "session_id": session_id,
            "mouse_name": dat["mouse_name"],
            "date_exp": dat["date_exp"],
            "n_trials": n_trials,
            "n_neurons": spks.shape[0],
            "brain_areas": ";".join(regions),
        })

    return pd.DataFrame(trial_rows), pd.DataFrame(session_rows), pd.DataFrame(region_rows)


if __name__ == "__main__":
    download_parts()
    alldat = load_all_sessions()
    trials_df, sessions_df, region_df = flatten_to_trials(alldat)
    trials_df.to_csv(os.path.join(RAW_DIR, "steinmetz_trials_raw.csv"), index=False)
    sessions_df.to_csv(os.path.join(RAW_DIR, "steinmetz_sessions_raw.csv"), index=False)
    region_df.to_csv(os.path.join(RAW_DIR, "steinmetz_region_activity_raw.csv"), index=False)
    print(f"Wrote {len(trials_df)} trial rows across {len(sessions_df)} sessions.")
    print(f"Region-activity matrix: {region_df.shape[0]} rows x {region_df.shape[1]} columns.")
