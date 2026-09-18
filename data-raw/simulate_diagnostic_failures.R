#' Simulate datasets that FAIL a diagnostic check, on purpose
#'
#' @description
#' Every other simulated dataset in this repo is built so that the "correct"
#' model recovers the truth cleanly -- which is exactly right for teaching
#' how to fit a model, but it never shows students what a BAD diagnostic
#' plot looks like. These two datasets are the deliberate counterexample:
#' each is set up so that a naive, seemingly reasonable model produces a
#' clearly diagnosable problem, one classic failure mode per domain.
#'
#'   - Bio:   heteroscedasticity. Calcium-imaging response amplitude vs.
#'            stimulation intensity. The true relationship is linear, but
#'            noise is multiplicative (scales with signal size) rather than
#'            constant -- a common and realistic feature of imaging data.
#'            Fitting ordinary linear regression produces a classic
#'            "fan"/"megaphone" shaped residuals-vs-fitted plot.
#'   - Psych: misspecified functional form. Recall accuracy vs. study time.
#'            The true relationship is a saturating (diminishing-returns)
#'            curve, not a straight line. Fitting a linear model to it
#'            produces a classic "U-shaped"/arc-shaped residuals-vs-fitted
#'            plot -- systematic under- and over-prediction across the range.
#'
#' Ground truth (instructor answer key):
#'   - Bio:   true model is amplitude = 0.5 + 0.08 * intensity, with noise
#'            SD = 0.15 * amplitude (multiplicative, not constant).
#'   - Psych: true model is accuracy = 0.95 * (1 - exp(-study_min / 12)),
#'            a saturating exponential-approach curve; NOT linear.
#'
#' @details
#' Run from the repository root. Writes 2 CSVs plus a data dictionary to
#' `data/diagnostic_failures/`. Intended use: have students fit the "obvious"
#' model (linear regression, in both cases) and produce a residuals-vs-fitted
#' plot and a QQ plot as usual -- then discuss what the resulting shape means
#' and what alternative model would fix it (e.g., a log-transform or
#' weighted regression for the Bio case; a saturating nonlinear model,
#' as in the dose-response week, for the Psych case).
#'
#' @author JMG
#' @date 2026-09-16 (edit to reflect actual creation date)
#' @seealso data/diagnostic_failures/diagnostic_failures_dictionary.md

library(tidyverse)

set.seed(20260919)

out_dir <- file.path("data", "diagnostic_failures")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ---- Ground-truth parameters ------------------------------------------------

# Bio: heteroscedasticity (multiplicative noise)
bio_intercept   <- 0.5
bio_slope       <- 0.08
bio_noise_frac  <- 0.15     # noise SD = this fraction of the true mean response
bio_n           <- 60
bio_intensity   <- runif(bio_n, min = 1, max = 40)

# Psych: misspecified functional form (true curve, fit as if linear)
psych_asymptote <- 0.95
psych_rate      <- 12       # time constant, minutes
psych_noise_sd  <- 0.05
psych_n         <- 60
psych_study_min <- runif(psych_n, min = 1, max = 45)

# ---- Bio: heteroscedastic calcium-imaging data ------------------------------

bio_true_mean <- bio_intercept + bio_slope * bio_intensity
bio_noise_sd  <- bio_noise_frac * bio_true_mean          # noise scales with signal
bio_amplitude <- pmax(0, bio_true_mean + rnorm(bio_n, 0, bio_noise_sd))

calcium_heteroscedastic_bio <- tibble(
  neuron_id = sprintf("N%02d", 1:bio_n),
  stim_intensity = round(bio_intensity, 2),
  amplitude = round(bio_amplitude, 3)
)
write_csv(calcium_heteroscedastic_bio, file.path(out_dir, "calcium_heteroscedastic_bio.csv"))

# ---- Psych: nonlinear recall-vs-study-time data -----------------------------

psych_true_mean <- psych_asymptote * (1 - exp(-psych_study_min / psych_rate))
psych_accuracy  <- pmin(1, pmax(0, psych_true_mean + rnorm(psych_n, 0, psych_noise_sd)))

recall_nonlinear_psych <- tibble(
  participant_id = sprintf("P%03d", 1:psych_n),
  study_min = round(psych_study_min, 1),
  accuracy = round(psych_accuracy, 3)
)
write_csv(recall_nonlinear_psych, file.path(out_dir, "recall_nonlinear_psych.csv"))

# ---- Sanity check: confirm the naive linear fit actually looks bad ---------
# (Run interactively before distributing to students; not required for
#  dataset generation itself.)

# bio_fit <- lm(amplitude ~ stim_intensity, data = calcium_heteroscedastic_bio)
# plot(fitted(bio_fit), resid(bio_fit))  # should visibly fan out
#
# psych_fit <- lm(accuracy ~ study_min, data = recall_nonlinear_psych)
# plot(fitted(psych_fit), resid(psych_fit))  # should show a clear arc/U-shape

# ---- Data dictionary ---------------------------------------------------------

dict <- c(
  "# Data Dictionary: Diagnostic-Failure Demo Datasets",
  "",
  "## calcium_heteroscedastic_bio.csv",
  "- `neuron_id`: simulated neuron identifier (60 neurons)",
  "- `stim_intensity`: stimulation intensity (arbitrary units, 1-40)",
  "- `amplitude`: calcium-imaging response amplitude (a.u.)",
  "- Designed so that fitting `lm(amplitude ~ stim_intensity)` produces a fan-shaped residuals-vs-fitted plot: noise SD scales with the signal (multiplicative noise), not constant.",
  "",
  "## recall_nonlinear_psych.csv",
  "- `participant_id`: simulated participant (60 participants)",
  "- `study_min`: study time in minutes (1-45)",
  "- `accuracy`: recall accuracy (proportion correct, 0-1)",
  "- Designed so that fitting `lm(accuracy ~ study_min)` produces a U-shaped/arc-shaped residuals-vs-fitted plot: the true relationship is a saturating exponential-approach curve, not a straight line.",
  "",
  "## Ground truth (instructor answer key)",
  paste0("- Bio: true model amplitude = ", bio_intercept, " + ", bio_slope, " * intensity; noise SD = ", bio_noise_frac, " * true mean (multiplicative)"),
  paste0("- Psych: true model accuracy = ", psych_asymptote, " * (1 - exp(-study_min / ", psych_rate, ")); NOT linear"),
  "",
  "## Suggested use",
  "Have students fit the obvious/naive model first (linear regression in both cases), produce the standard residuals-vs-fitted and QQ diagnostic plots, and discuss: what does the shape tell you, and what would you do instead? (A log-transform or weighted regression for the Bio case; a saturating nonlinear model, as in the dose-response week, for the Psych case.) Pairs well with the diagnostic-plot checks already built into the regression, ANOVA, curve-fitting, and mixed-model weeks -- this is the deliberate 'what does it look like when it's wrong' counterpart to those."
)

writeLines(dict, file.path(out_dir, "diagnostic_failures_dictionary.md"))

message("Done. Wrote 2 CSVs + 1 data dictionary to ", out_dir)
