# Data Dictionary: Nonlinear Curve Fitting Datasets

## dose_response_bio.csv
- `dose_uM`: drug concentration in micromolar (8 log-spaced doses, 0.1-300)
- `replicate`: replicate measurement index (4 per dose)
- `firing_rate`: neuronal firing rate response (spikes/sec)

## psychophysics_psych.csv
- `intensity`: stimulus intensity (1-9, arbitrary units)
- `trial`: trial index within that intensity (40 trials per intensity)
- `detected`: 1 if the participant reported detecting the stimulus, else 0

## Ground truth (instructor answer key)
- Bio Hill curve: baseline = 2, max response = 22, true EC50 = 10 uM, true Hill slope = 1.8
- Psych psychometric function: true threshold = 5, true slope = 1.2
