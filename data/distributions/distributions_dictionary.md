# Data Dictionary: Probability Distributions Datasets

## spike_counts_bio.csv
- `neuron_id`: simulated neuron identifier (30 neurons)
- `trial`: trial number (1-40)
- `spike_count`: spikes observed in a 1-second window. True generating process: Poisson(lambda = 8).

## inter_spike_intervals_bio.csv
- `neuron_id`: simulated neuron identifier
- `isi_index`: index within that neuron's spike train (1-200)
- `isi_sec`: inter-spike interval in seconds. True generating process: Exponential(rate = 8).

## forced_choice_accuracy_psych.csv
- `participant_id`: simulated participant (45 participants)
- `n_trials`: number of forced-choice trials attempted (60, fixed)
- `n_correct`: number correct. True generating process: Binomial(n = 60, p = 0.72).

## reaction_times_psych.csv
- `participant_id`: simulated participant
- `trial`: trial number (1-60)
- `rt_ms`: reaction time in milliseconds. True generating process: Log-Normal(meanlog = log(650), sdlog = 0.35).

## Ground truth (instructor answer key — do not distribute to students up front)
- True firing rate (Poisson lambda / Exponential rate): 8
- True forced-choice accuracy (Binomial p): 0.72
- True RT distribution: Log-Normal(meanlog = log(650) = 6.477, sdlog = 0.35)
