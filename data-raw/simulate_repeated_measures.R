#' Simulate datasets for the Repeated-Measures / Pivoting / Mixed-Models topic
#'
#' @description
#' Generates two paired datasets, each deliberately distributed in WIDE format
#' (one column per trial) because that's how repeated-measures data usually
#' actually arrives — the pivot to long format is a genuine prerequisite to
#' analysis here, not a manufactured exercise. Each also has a small, separate
#' metadata file that must be joined in, and a sprinkling of real missingness.
#'
#'   - Bio:   calcium-imaging response amplitude, one row per neuron, one
#'            column per trial. Neurons vary in a true random intercept
#'            (baseline responsiveness) and belong to one of two genotypes
#'            (stored in a separate metadata file -> requires a join).
#'   - Psych: reaction time, one row per participant, one column per trial.
#'            Participants vary in a true random intercept (baseline speed)
#'            and belong to one of two task-difficulty groups (separate
#'            metadata file -> requires a join).
#'
#' Ground truth (instructor answer key):
#'   - Bio:   grand mean amplitude = 1.0 (a.u.); genotype B adds a true fixed
#'            effect of +0.35; true between-neuron SD (random intercept) = 0.25;
#'            true trial-level noise SD = 0.4. ~4% of trial values are missing
#'            (simulating dropped frames).
#'   - Psych: grand mean RT = 550 ms; difficulty group "hard" adds a true fixed
#'            effect of +80 ms; true between-participant SD (random intercept)
#'            = 40 ms; true trial-level noise SD = 60 ms. ~4% of trials are
#'            missing (simulating a missed response / equipment glitch).
#'
#' @details
#' Run from the repository root. Writes 4 CSVs (2 wide response files +
#' 2 metadata files) plus a data dictionary to `data/repeated_measures/`.
#' The intended student workflow: read both files for a domain, pivot the
#' wide file to long with `pivot_longer()`, join the metadata with
#' `left_join()`, then fit a mixed-effects model with `lme4::lmer()`.
#'
#' @author JMG
#' @date 2026-09-16 (edit to reflect actual creation date)
#' @seealso data/repeated_measures/repeated_measures_dictionary.md


set.seed(20260917)

out_dir <- file.path("data", "repeated_measures")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ---- Ground-truth parameters ------------------------------------------------

n_neurons        <- 24
n_trials_bio      <- 10
bio_grand_mean    <- 1.0
bio_genotype_effect <- 0.35     # genotype "B" vs. reference "A"
bio_between_sd    <- 0.25       # true random-intercept SD across neurons
bio_trial_sd      <- 0.40       # true trial-level noise SD
bio_missing_rate  <- 0.04

n_participants    <- 40
n_trials_psych    <- 12
psych_grand_mean  <- 550        # ms
psych_difficulty_effect <- 80   # "hard" vs. reference "easy"
psych_between_sd  <- 40         # true random-intercept SD across participants
psych_trial_sd    <- 60         # true trial-level noise SD
psych_missing_rate <- 0.04

# ---- Bio: calcium-imaging amplitude, wide format ----------------------------

neuron_ids <- sprintf("N%02d", 1:n_neurons)
genotype   <- sample(c("A", "B"), n_neurons, replace = TRUE)
neuron_intercept <- rnorm(n_neurons, mean = 0, sd = bio_between_sd)

bio_wide <- data.frame(neuron_id = neuron_ids)
for (t in 1:n_trials_bio) {
  genotype_effect <- ifelse(genotype == "B", bio_genotype_effect, 0)
  trial_values <- bio_grand_mean + genotype_effect + neuron_intercept +
    rnorm(n_neurons, mean = 0, sd = bio_trial_sd)
  # introduce missingness
  is_missing <- runif(n_neurons) < bio_missing_rate
  trial_values[is_missing] <- NA
  bio_wide[[paste0("trial_", t)]] <- round(trial_values, 3)
}

write.csv(bio_wide, file.path(out_dir, "calcium_amplitude_wide_bio.csv"), row.names = FALSE)

bio_metadata <- data.frame(neuron_id = neuron_ids, genotype = genotype)
write.csv(bio_metadata, file.path(out_dir, "neuron_metadata_bio.csv"), row.names = FALSE)

# ---- Psych: reaction time, wide format ---------------------------------------

participant_ids <- sprintf("P%03d", 1:n_participants)
difficulty <- sample(c("easy", "hard"), n_participants, replace = TRUE)
participant_intercept <- rnorm(n_participants, mean = 0, sd = psych_between_sd)

psych_wide <- data.frame(participant_id = participant_ids)
for (t in 1:n_trials_psych) {
  difficulty_effect <- ifelse(difficulty == "hard", psych_difficulty_effect, 0)
  trial_values <- psych_grand_mean + difficulty_effect + participant_intercept +
    rnorm(n_participants, mean = 0, sd = psych_trial_sd)
  is_missing <- runif(n_participants) < psych_missing_rate
  trial_values[is_missing] <- NA
  psych_wide[[paste0("trial_", t)]] <- round(trial_values, 1)
}

write.csv(psych_wide, file.path(out_dir, "reaction_time_wide_psych.csv"), row.names = FALSE)

psych_metadata <- data.frame(participant_id = participant_ids, difficulty = difficulty)
write.csv(psych_metadata, file.path(out_dir, "participant_metadata_psych.csv"), row.names = FALSE)

# ---- Sanity check: confirm the pivot + join + lmer workflow recovers truth ---
# (Run interactively to verify before distributing to students; not required
#  for the dataset generation itself.)

# bio_long <- bio_wide |>
#   pivot_longer(starts_with("trial_"), names_to = "trial", values_to = "amplitude") |>
#   left_join(bio_metadata, by = "neuron_id") |>
#   drop_na(amplitude)
# lme4::lmer(amplitude ~ genotype + (1 | neuron_id), data = bio_long) |> summary()
# -- fixed effect for genotypeB should recover ~0.35

# ---- Data dictionary ----------------------------------------------------------

dict <- c(
  "# Data Dictionary: Repeated-Measures / Pivoting / Mixed-Models Datasets",
  "",
  "## calcium_amplitude_wide_bio.csv",
  "- `neuron_id`: simulated neuron identifier (24 neurons)",
  "- `trial_1` ... `trial_10`: response amplitude (a.u.) for that trial. WIDE format — pivot to long before analysis.",
  "- Some cells are NA (~4% missing), simulating dropped imaging frames.",
  "",
  "## neuron_metadata_bio.csv",
  "- `neuron_id`: join key to calcium_amplitude_wide_bio.csv",
  "- `genotype`: \"A\" (reference) or \"B\" (true fixed effect +0.35 on amplitude)",
  "",
  "## reaction_time_wide_psych.csv",
  "- `participant_id`: simulated participant (40 participants)",
  "- `trial_1` ... `trial_12`: reaction time in ms for that trial. WIDE format — pivot to long before analysis.",
  "- Some cells are NA (~4% missing), simulating missed responses.",
  "",
  "## participant_metadata_psych.csv",
  "- `participant_id`: join key to reaction_time_wide_psych.csv",
  "- `difficulty`: \"easy\" (reference) or \"hard\" (true fixed effect +80 ms on RT)",
  "",
  "## Ground truth (instructor answer key)",
  paste0("- Bio: grand mean = ", bio_grand_mean, "; genotype B effect = +", bio_genotype_effect,
         "; between-neuron SD = ", bio_between_sd, "; trial-level noise SD = ", bio_trial_sd),
  paste0("- Psych: grand mean = ", psych_grand_mean, " ms; hard-difficulty effect = +", psych_difficulty_effect,
         " ms; between-participant SD = ", psych_between_sd, "; trial-level noise SD = ", psych_trial_sd)
)

writeLines(dict, file.path(out_dir, "repeated_measures_dictionary.md"))

message("Done. Wrote 4 CSVs + 1 data dictionary to ", out_dir)
