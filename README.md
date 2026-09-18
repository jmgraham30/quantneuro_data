# Quantitative Neuroscience — Course Datasets

A curated collection of real and simulated datasets for teaching applied statistics,
data wrangling, and computational modeling to neuroscience students. Wherever
possible, there is a pairing of one example from cellular/systems neuroscience and one from human
cognitive/behavioral neuroscience.


## How this repo is organized

```
quantneuro-data/
├── README.md              <- this file, with the dataset index table below
├── CURATION_PLAN.md        <- full topic-by-topic real-vs-simulated roadmap
├── data-raw/                <- scripts that generate or clean each dataset (source of truth)
│   ├── simulate_distributions.R
│   ├── simulate_repeated_measures.R
│   ├── simulate_dose_response.R
│   ├── simulate_diagnostic_failures.R
│   ├── prepare_steinmetz.R          <- real data; run AFTER python_prep/export_steinmetz_trials.py
│   ├── prepare_ibl.R                <- real data; run AFTER python_prep/export_ibl_trials.py
│   ├── prepare_physionet_eeg.R      <- real data; pure R (needs `edfReader` package)
│   ├── prepare_crcns_template.R     <- STARTER TEMPLATE ONLY, see file header
│   └── python_prep/                 <- one-time Python export scripts (Steinmetz/IBL only;
│       ├── export_steinmetz_trials.py   their source formats aren't R-readable directly)
│       └── export_ibl_trials.py
├── data/                     <- output CSVs, one subfolder per topic
│   └── <topic>/
│       ├── <topic>_bio.csv
│       ├── <topic>_psych.csv
│       └── <topic>_dictionary.md   <- column-by-column documentation
└── R/                          <- (future) helper functions, once this becomes a package
```

For the simulated datasets, the R code used for generating the data can be found in the scripts
in the `data-raw/` directory. Everything is fully reproducible and uses a
fixed `set.seed()`. The **ground-truth parameters** used for simulations are in the header comment
— the whole point of simulating is that you know the right answer, so say what it is.

Every real dataset gets a short reference in the table below
and in its `_dictionary.md` file.

**A note on the four newer real-data sources (Steinmetz, IBL, PhysioNet, CRCNS):** these were
added from verified, correctly-documented access methods, but have not been run end-to-end
against live data in the environment that built this repo (no network access to osf.io,
figshare.com, physionet.org, or crcns.org from there). `prepare_physionet_eeg.R` is fully R/
tidyverse and should just work. `prepare_steinmetz.R` and `prepare_ibl.R` each need a one-time
Python export step first (see `data-raw/python_prep/`) because their native source formats
genuinely aren't R-readable, not by choice. `prepare_crcns_template.R` is explicitly a starting
skeleton, not a finished script — CRCNS has no single consistent format across datasets. Run each
once and sanity-check the output before relying on it in class.

## Dataset index

| Topic | Domain | Type | Dataset | Source / Script |
|---|---|---|---|---|
| Probability distributions | Bio | Simulated | Spike counts (Poisson) & inter-spike intervals (Exponential) | `data-raw/simulate_distributions.R` |
| Probability distributions | Psych | Simulated | Forced-choice accuracy (Binomial) & reaction times (skewed) | `data-raw/simulate_distributions.R` |
| Repeated measures / pivoting / mixed models | Bio | Simulated | Calcium-imaging trials, wide format, with missingness | `data-raw/simulate_repeated_measures.R` |
| Repeated measures / pivoting / mixed models | Psych | Simulated | RT trials, wide format, with missingness | `data-raw/simulate_repeated_measures.R` |
| Nonlinear curve fitting | Bio | Simulated | Dose-response curve (known EC50 & Hill slope) | `data-raw/simulate_dose_response.R` |
| Nonlinear curve fitting | Psych | Simulated | Psychophysical function (known threshold & slope) | `data-raw/simulate_dose_response.R` |
| Diagnostic-failure demo (what a bad diagnostic plot looks like) | Bio | Simulated | Calcium-imaging amplitude vs. intensity, deliberately heteroscedastic (fan-shaped residuals under OLS) | `data-raw/simulate_diagnostic_failures.R` |
| Diagnostic-failure demo (what a bad diagnostic plot looks like) | Psych | Simulated | Recall accuracy vs. study time, deliberately nonlinear (arc-shaped residuals under a linear fit) | `data-raw/simulate_diagnostic_failures.R` |
| Descriptive stats, t-tests, ANOVA, regression, PCA, classification | Bio | Real | Allen Institute Cell Types Database | [Allen Cell Types](https://celltypes.brain-map.org/), via [Juavinett's teaching materials](https://github.com/ajuavinett) |
| Descriptive stats, t-tests, ANOVA, regression, reading a paper | Psych | Real | Open Stats Lab datasets (paired with *Psychological Science* articles) | [Open Stats Lab](https://sites.google.com/view/openstatslab/home) |
| Additional psych datasets / lab manual model | Psych | Real | Crump Lab open stats lab manual | [crumplab.com/statisticsLab](https://crumplab.com/statisticsLab/) (CC BY-SA) |
| Dimensionality reduction (PCA); logistic regression / classification | Bio | Real | Steinmetz et al. (2019) mouse Neuropixels decision task \u2014 trial behavior + per-region population activity | `data-raw/prepare_steinmetz.R` (after `python_prep/export_steinmetz_trials.py`); [paper](https://doi.org/10.1038/s41586-019-1787-x), CC-BY-4.0 |
| Signal Detection Theory (real Bio-side alternative to the simulated SDT task) | Bio | Real | IBL mouse visual-contrast decision task, trial-level choice/contrast/feedback | `data-raw/prepare_ibl.R` (after `python_prep/export_ibl_trials.py`); [paper](https://doi.org/10.1101/2023.07.04.547681) |
| Time-series / signal basics (real Psych-side alternative/companion to the simulated signal) | Psych | Real | PhysioNet EEG Motor Movement/Imagery dataset, human 64-channel EEG | `data-raw/prepare_physionet_eeg.R`; [PhysioNet](https://physionet.org/content/eegmmidb/1.0.0/), ODbL |
| Not yet assigned to a specific topic \u2014 template only | \u2014 | Real (heterogeneous) | CRCNS.org \u2014 ~150 electrophysiology/fMRI/EEG/eye-movement datasets; registration required, no consistent format | `data-raw/prepare_crcns_template.R` (starter skeleton, not a finished pipeline \u2014 see file header) |
| *(rows to be added as each topic is built — see CURATION_PLAN.md)* | | | | |


