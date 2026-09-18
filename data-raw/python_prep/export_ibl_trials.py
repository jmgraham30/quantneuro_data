"""
One-time export step: International Brain Laboratory (IBL) trial data.

WHY PYTHON, HERE ONLY: IBL data is accessed through their own "ONE" (Open
Neurophysiology Environment) client library, not a plain download URL --
same underlying reason as the Steinmetz script in this folder. This script
exports just the `trials` object (behavioral data only, no spike data) for
a handful of sessions into a flat CSV; everything after that is R/tidyverse.

Source: International Brain Laboratory et al. (2023). A Brain-Wide Map of
Neural Activity during Complex Behaviour.
https://doi.org/10.1101/2023.07.04.547681
Data access: https://int-brain-lab.github.io/iblenv/03_one.html

This dataset is a deliberate PAIR to the Steinmetz export in this folder:
both are mouse visual-contrast decision tasks, but this one is kept to
trial-level behavior only (contrast/choice/feedback), making it a real-data
stand-in for the Signal Detection Theory week specifically -- contrast level
is a genuine signal-strength manipulation, and "choice" is a genuine
detection-style response, not a simulated proxy for one.

Run this once, from the repository root:
    python data-raw/python_prep/export_ibl_trials.py
Requires: ONE-api (pip install ONE-api), pandas
Writes: data-raw/python_prep/ibl_trials_raw.csv

Author: JMG
Date: 2026-09-16 (edit to reflect actual run date)
"""

import os
import pandas as pd
from one.api import ONE

RAW_DIR = os.path.join("data-raw", "python_prep")
os.makedirs(RAW_DIR, exist_ok=True)

# Adjust N_SESSIONS to taste -- a handful of sessions is plenty for teaching;
# the full brain-wide map is hundreds of sessions and far more than needed.
N_SESSIONS = 10


def main():
    one = ONE(base_url="https://openalyx.internationalbrainlab.org", silent=True)
    sessions = one.search(dataset="trials")[:N_SESSIONS]

    rows = []
    for session_id in sessions:
        trials = one.load_object(session_id, "trials")
        n_trials = len(trials["choice"])
        for t in range(n_trials):
            rows.append({
                "session_id": str(session_id),
                "trial": t,
                "contrast_left": trials["contrastLeft"][t],
                "contrast_right": trials["contrastRight"][t],
                "choice": trials["choice"][t],          # -1, 0, 1
                "feedback_type": trials["feedbackType"][t],  # 1 = correct, -1 = incorrect
                "response_time": float(
                    trials["response_times"][t] - trials["goCue_times"][t]
                ),
            })

    df = pd.DataFrame(rows)
    df.to_csv(os.path.join(RAW_DIR, "ibl_trials_raw.csv"), index=False)
    print(f"Wrote {len(df)} trial rows across {len(sessions)} sessions.")


if __name__ == "__main__":
    main()
