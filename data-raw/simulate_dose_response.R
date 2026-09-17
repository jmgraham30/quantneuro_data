#' Simulate datasets for the Nonlinear Curve Fitting topic
#'
#' @description
#' Generates two paired datasets, each following a sigmoidal (logistic) curve
#' with KNOWN true parameters, so students can fit a model with `nls()` and
#' directly check whether their fitted parameters recover the truth.
#'
#'   - Bio:   a dose-response curve — drug concentration (log-spaced, as is
#'            standard practice) vs. neuronal firing-rate response, following
#'            a four-parameter log-logistic (Hill) curve.
#'   - Psych: a psychophysical function — stimulus intensity vs. proportion
#'            of "detected" responses, following a logistic psychometric
#'            function with a true threshold and slope.
#'
#' Ground truth (instructor answer key):
#'   - Bio:   baseline response = 2 (spikes/sec), max response = 22,
#'            true EC50 = 10 (micromolar), true Hill slope = 1.8.
#'   - Psych: true threshold (50%-detection point) = 5.0 (stimulus units),
#'            true slope = 1.2.
#'
#' @details
#' Run from the repository root. Writes 2 CSVs plus a data dictionary to
#' `data/dose_response/`. Both datasets include per-observation noise, so
#' recovered parameters will be close to, but not exactly, the ground truth
#' above — that's a deliberate and useful discussion point, not an error.
#'
#' @author [Your Name]
#' @date 2026-09-16 (edit to reflect actual creation date)
#' @seealso data/dose_response/dose_response_dictionary.md


set.seed(20260918)

out_dir <- file.path("data", "dose_response")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ---- Ground-truth parameters ------------------------------------------------

# Bio: four-parameter log-logistic (Hill) dose-response curve
bio_baseline   <- 2      # response at zero/very low dose
bio_max_resp   <- 22     # response at saturating dose
bio_true_EC50  <- 10     # micromolar
bio_true_hill  <- 1.8    # Hill slope
bio_noise_sd   <- 1.5
bio_n_reps     <- 4      # replicate measurements per dose
bio_doses      <- c(0.1, 0.3, 1, 3, 10, 30, 100, 300)  # micromolar, log-spaced

# Psych: logistic psychometric function
psych_true_threshold <- 5.0   # stimulus units at 50% detection
psych_true_slope     <- 1.2
psych_n_trials_per_intensity <- 40
psych_intensities <- seq(1, 9, by = 1)  # stimulus units

# ---- Bio: dose-response curve -----------------------------------------------

hill_fn <- function(dose, baseline, max_resp, ec50, hill) {
  baseline + (max_resp - baseline) * (dose^hill) / (ec50^hill + dose^hill)
}

bio_rows <- lapply(bio_doses, function(d) {
  true_resp <- hill_fn(d, bio_baseline, bio_max_resp, bio_true_EC50, bio_true_hill)
  noisy_resp <- true_resp + rnorm(bio_n_reps, 0, bio_noise_sd)
  data.frame(
    dose_uM = d,
    replicate = 1:bio_n_reps,
    firing_rate = round(pmax(0, noisy_resp), 2)  # firing rate can't go below 0
  )
})
dose_response_bio <- do.call(rbind, bio_rows)

write.csv(dose_response_bio, file.path(out_dir, "dose_response_bio.csv"), row.names = FALSE)

# ---- Psych: psychophysical function -----------------------------------------
# Simulate individual detection trials (0/1) at each intensity, so students
# can either work with trial-level binary data (for a GLM) or aggregate to
# proportions first (for nls()) — both are legitimate approaches, deliberately.

logistic_fn <- function(x, threshold, slope) {
  1 / (1 + exp(-slope * (x - threshold)))
}

psych_rows <- lapply(psych_intensities, function(x) {
  true_p <- logistic_fn(x, psych_true_threshold, psych_true_slope)
  detected <- rbinom(psych_n_trials_per_intensity, size = 1, prob = true_p)
  data.frame(
    intensity = x,
    trial = 1:psych_n_trials_per_intensity,
    detected = detected
  )
})
psychophysics_psych <- do.call(rbind, psych_rows)

write.csv(psychophysics_psych, file.path(out_dir, "psychophysics_psych.csv"), row.names = FALSE)

# ---- Sanity check (run interactively before distributing) -------------------

# bio_fit <- nls(firing_rate ~ baseline + (maxr - baseline) * dose_uM^hill / (ec50^hill + dose_uM^hill),
#                data = dose_response_bio,
#                start = list(baseline = 1, maxr = 20, ec50 = 8, hill = 1.5))
# coef(bio_fit)  # should be close to baseline=2, maxr=22, ec50=10, hill=1.8

# ---- Data dictionary ----------------------------------------------------------

dict <- c(
  "# Data Dictionary: Nonlinear Curve Fitting Datasets",
  "",
  "## dose_response_bio.csv",
  "- `dose_uM`: drug concentration in micromolar (8 log-spaced doses, 0.1-300)",
  "- `replicate`: replicate measurement index (4 per dose)",
  "- `firing_rate`: neuronal firing rate response (spikes/sec)",
  "",
  "## psychophysics_psych.csv",
  "- `intensity`: stimulus intensity (1-9, arbitrary units)",
  "- `trial`: trial index within that intensity (40 trials per intensity)",
  "- `detected`: 1 if the participant reported detecting the stimulus, else 0",
  "",
  "## Ground truth (instructor answer key)",
  paste0("- Bio Hill curve: baseline = ", bio_baseline, ", max response = ", bio_max_resp,
         ", true EC50 = ", bio_true_EC50, " uM, true Hill slope = ", bio_true_hill),
  paste0("- Psych psychometric function: true threshold = ", psych_true_threshold,
         ", true slope = ", psych_true_slope)
)

writeLines(dict, file.path(out_dir, "dose_response_dictionary.md"))

message("Done. Wrote 2 CSVs + 1 data dictionary to ", out_dir)
