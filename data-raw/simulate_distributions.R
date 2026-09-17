#' Simulate datasets for the Probability Distributions topic
#'
#' @description
#' Generates two paired datasets illustrating why the *shape* of the data
#' generating process matters for choosing an analysis, rather than defaulting
#' to "assume normal":
#'
#'   - Bio:   single-neuron spike counts per trial (Poisson) and the
#'            inter-spike intervals within trials (Exponential).
#'   - Psych: forced-choice accuracy per participant (Binomial) and
#'            reaction times (right-skewed, simulated via a log-normal,
#'            a common simple stand-in for the ex-Gaussian shape real RT
#'            data usually shows).
#'
#' Ground truth (for the instructor / answer key — do not give these numbers
#' to students up front; the point of the lab is to recover them from data):
#'   - Bio:   true firing rate lambda = 8 spikes/sec over a 1-second window;
#'            true mean inter-spike interval = 1/lambda seconds (Exponential
#'            rate = lambda).
#'   - Psych: true accuracy p = 0.72; true RT distribution has
#'            meanlog = log(650), sdlog = 0.35 (on the millisecond scale),
#'            i.e. a right-skewed distribution with median RT ~ 650 ms.
#'
#' @details
#' Run this script from the repository root (`Rscript data-raw/simulate_distributions.R`).
#' It writes four CSVs to `data/distributions/` plus a data dictionary.
#'
#' @author [Your Name]
#' @date 2026-09-16 (edit to reflect actual creation date)
#' @seealso data/distributions/distributions_dictionary.md


set.seed(20260916)  # fixed seed: reproducible for every student, every semester

out_dir <- file.path("data", "distributions")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ---- Ground-truth parameters (documented once, used everywhere below) ------

n_neurons      <- 30      # number of simulated "neurons" (independent units)
n_trials       <- 40      # trials per neuron
true_lambda    <- 8       # true firing rate, spikes/sec, over a 1-sec window

n_participants <- 45
n_forced_choice_trials <- 60
true_accuracy  <- 0.72    # true P(correct) per trial
true_rt_meanlog <- log(650)  # ms scale
true_rt_sdlog   <- 0.35

# ---- Bio: spike counts (Poisson) --------------------------------------------

spike_counts <- data.frame(
  neuron_id = rep(sprintf("N%02d", 1:n_neurons), each = n_trials),
  trial     = rep(1:n_trials, times = n_neurons),
  spike_count = rpois(n_neurons * n_trials, lambda = true_lambda)
)

write.csv(spike_counts, file.path(out_dir, "spike_counts_bio.csv"), row.names = FALSE)

# ---- Bio: inter-spike intervals (Exponential) -------------------------------
# One long train of ISIs per neuron, in seconds. Mean ISI = 1/true_lambda.

n_isis_per_neuron <- 200

isi_list <- lapply(1:n_neurons, function(i) {
  data.frame(
    neuron_id = sprintf("N%02d", i),
    isi_index = 1:n_isis_per_neuron,
    isi_sec   = rexp(n_isis_per_neuron, rate = true_lambda)
  )
})
inter_spike_intervals <- do.call(rbind, isi_list)

write.csv(inter_spike_intervals, file.path(out_dir, "inter_spike_intervals_bio.csv"), row.names = FALSE)

# ---- Psych: forced-choice accuracy (Binomial) -------------------------------
# One row per participant: number of correct trials out of n_forced_choice_trials.

forced_choice_accuracy <- data.frame(
  participant_id = sprintf("P%03d", 1:n_participants),
  n_trials    = n_forced_choice_trials,
  n_correct   = rbinom(n_participants, size = n_forced_choice_trials, prob = true_accuracy)
)

write.csv(forced_choice_accuracy, file.path(out_dir, "forced_choice_accuracy_psych.csv"), row.names = FALSE)

# ---- Psych: reaction times (right-skewed) -----------------------------------
# Trial-level RTs per participant; deliberately NOT normal.

rt_list <- lapply(1:n_participants, function(i) {
  data.frame(
    participant_id = sprintf("P%03d", i),
    trial = 1:n_forced_choice_trials,
    rt_ms = rlnorm(n_forced_choice_trials, meanlog = true_rt_meanlog, sdlog = true_rt_sdlog)
  )
})
reaction_times <- do.call(rbind, rt_list)

write.csv(reaction_times, file.path(out_dir, "reaction_times_psych.csv"), row.names = FALSE)

# ---- Data dictionary ---------------------------------------------------------

dict <- c(
  "# Data Dictionary: Probability Distributions Datasets",
  "",
  "## spike_counts_bio.csv",
  "- `neuron_id`: simulated neuron identifier (30 neurons)",
  "- `trial`: trial number (1-40)",
  "- `spike_count`: spikes observed in a 1-second window. True generating process: Poisson(lambda = 8).",
  "",
  "## inter_spike_intervals_bio.csv",
  "- `neuron_id`: simulated neuron identifier",
  "- `isi_index`: index within that neuron's spike train (1-200)",
  "- `isi_sec`: inter-spike interval in seconds. True generating process: Exponential(rate = 8).",
  "",
  "## forced_choice_accuracy_psych.csv",
  "- `participant_id`: simulated participant (45 participants)",
  "- `n_trials`: number of forced-choice trials attempted (60, fixed)",
  "- `n_correct`: number correct. True generating process: Binomial(n = 60, p = 0.72).",
  "",
  "## reaction_times_psych.csv",
  "- `participant_id`: simulated participant",
  "- `trial`: trial number (1-60)",
  "- `rt_ms`: reaction time in milliseconds. True generating process: Log-Normal(meanlog = log(650), sdlog = 0.35).",
  "",
  "## Ground truth (instructor answer key — do not distribute to students up front)",
  paste0("- True firing rate (Poisson lambda / Exponential rate): ", true_lambda),
  paste0("- True forced-choice accuracy (Binomial p): ", true_accuracy),
  paste0("- True RT distribution: Log-Normal(meanlog = log(650) = ", round(true_rt_meanlog, 3), ", sdlog = ", true_rt_sdlog, ")")
)

writeLines(dict, file.path(out_dir, "distributions_dictionary.md"))

message("Done. Wrote 4 CSVs + 1 data dictionary to ", out_dir)
