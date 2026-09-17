# Data Dictionary: Diagnostic-Failure Demo Datasets

## calcium_heteroscedastic_bio.csv
- `neuron_id`: simulated neuron identifier (60 neurons)
- `stim_intensity`: stimulation intensity (arbitrary units, 1-40)
- `amplitude`: calcium-imaging response amplitude (a.u.)
- Designed so that fitting `lm(amplitude ~ stim_intensity)` produces a fan-shaped residuals-vs-fitted plot: noise SD scales with the signal (multiplicative noise), not constant.

## recall_nonlinear_psych.csv
- `participant_id`: simulated participant (60 participants)
- `study_min`: study time in minutes (1-45)
- `accuracy`: recall accuracy (proportion correct, 0-1)
- Designed so that fitting `lm(accuracy ~ study_min)` produces a U-shaped/arc-shaped residuals-vs-fitted plot: the true relationship is a saturating exponential-approach curve, not a straight line.

## Ground truth (instructor answer key)
- Bio: true model amplitude = 0.5 + 0.08 * intensity; noise SD = 0.15 * true mean (multiplicative)
- Psych: true model accuracy = 0.95 * (1 - exp(-study_min / 12)); NOT linear

## Suggested use
Have students fit the obvious/naive model first (linear regression in both cases), produce the standard residuals-vs-fitted and QQ diagnostic plots, and discuss: what does the shape tell you, and what would you do instead? (A log-transform or weighted regression for the Bio case; a saturating nonlinear model, as in the dose-response week, for the Psych case.) Pairs well with the diagnostic-plot checks already built into the regression, ANOVA, curve-fitting, and mixed-model weeks -- this is the deliberate 'what does it look like when it's wrong' counterpart to those.
