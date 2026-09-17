# Data Dictionary: Repeated-Measures / Pivoting / Mixed-Models Datasets

## calcium_amplitude_wide_bio.csv
- `neuron_id`: simulated neuron identifier (24 neurons)
- `trial_1` ... `trial_10`: response amplitude (a.u.) for that trial. WIDE format — pivot to long before analysis.
- Some cells are NA (~4% missing), simulating dropped imaging frames.

## neuron_metadata_bio.csv
- `neuron_id`: join key to calcium_amplitude_wide_bio.csv
- `genotype`: "A" (reference) or "B" (true fixed effect +0.35 on amplitude)

## reaction_time_wide_psych.csv
- `participant_id`: simulated participant (40 participants)
- `trial_1` ... `trial_12`: reaction time in ms for that trial. WIDE format — pivot to long before analysis.
- Some cells are NA (~4% missing), simulating missed responses.

## participant_metadata_psych.csv
- `participant_id`: join key to reaction_time_wide_psych.csv
- `difficulty`: "easy" (reference) or "hard" (true fixed effect +80 ms on RT)

## Ground truth (instructor answer key)
- Bio: grand mean = 1; genotype B effect = +0.35; between-neuron SD = 0.25; trial-level noise SD = 0.4
- Psych: grand mean = 550 ms; hard-difficulty effect = +80 ms; between-participant SD = 40; trial-level noise SD = 60
