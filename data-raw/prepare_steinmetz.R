#' Prepare the Steinmetz et al. (2019) mouse decision-making dataset
#'
#' @description
#' Cleans the CSVs produced by `data-raw/python_prep/export_steinmetz_trials.py`
#' (see that script for why a one-time Python step is unavoidable here) into
#' two tidy, course-ready outputs:
#'
#'   - `steinmetz_trials.csv`: one row per trial, behavioral variables only
#'     (contrast, choice, feedback, reaction time) -- usable for logistic
#'     regression / classification, or as a real-data companion to the
#'     Signal Detection Theory week (contrast level stands in for signal
#'     strength; "response" stands in for a perceptual decision).
#'   - `steinmetz_region_activity.csv`: one row per trial, one column per
#'     brain region (mean spike count in that region on that trial) --
#'     a genuine multi-feature, wide matrix, intended for the
#'     dimensionality-reduction (PCA) week. This is real, high-dimensional
#'     population activity, not a proxy for it.
#'
#' Both are joined against session-level metadata (mouse, date, region list)
#' so the join/wrangle skills already built into other weeks apply here too.
#'
#' @details
#' Source: Steinmetz, N.A., Zatka-Haas, P., Carandini, M. & Harris, K.D. (2019).
#' Distributed coding of choice, action, and engagement across the mouse brain.
#' Nature, 576, 266-273. https://doi.org/10.1038/s41586-019-1787-x
#' Data license: CC-BY-4.0. Cite the paper if these data are used in teaching
#' materials or publications, per the data source's own request.
#'
#' Run from the repository root, AFTER running the Python export script:
#'   python data-raw/python_prep/export_steinmetz_trials.py
#'   Rscript data-raw/prepare_steinmetz.R
#'
#' @author JMG
#' @date 2026-09-16 (edit to reflect actual run date)
#' @seealso data/steinmetz/steinmetz_dictionary.md

library(tidyverse)

raw_dir <- file.path("data-raw", "python_prep")
out_dir <- file.path("data", "steinmetz")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

raw_trial_path  <- file.path(raw_dir, "steinmetz_trials_raw.csv")
raw_session_path <- file.path(raw_dir, "steinmetz_sessions_raw.csv")
raw_region_path <- file.path(raw_dir, "steinmetz_region_activity_raw.csv")

if (!all(file.exists(raw_trial_path, raw_session_path, raw_region_path))) {
  stop(
    "Raw CSVs not found in ", raw_dir, ". Run the Python export first:\n",
    "  python data-raw/python_prep/export_steinmetz_trials.py"
  )
}

sessions_raw <- read_csv(raw_session_path, show_col_types = FALSE)

# ---- Trial-level behavioral dataset -----------------------------------------

trials <- read_csv(raw_trial_path, show_col_types = FALSE) |>
  left_join(
    sessions_raw |> select(session_id, date_exp, brain_areas),
    by = "session_id"
  ) |>
  mutate(
    # a genuine perceptual-decision framing, parallel to the Psych SDT week:
    # "signal strength" is however much stronger the correct-side contrast is
    signal_strength = abs(contrast_right - contrast_left),
    correct_response = case_when(
      contrast_right > contrast_left ~ 1,
      contrast_left > contrast_right ~ -1,
      TRUE ~ 0
    ),
    correct = as.integer(response == correct_response)
  ) |>
  relocate(session_id, mouse_name, date_exp, trial) |>
  arrange(session_id, trial)

write_csv(trials, file.path(out_dir, "steinmetz_trials.csv"))

# ---- Region-activity matrix, for PCA ----------------------------------------

region_activity <- read_csv(raw_region_path, show_col_types = FALSE) |>
  left_join(
    sessions_raw |> select(session_id, mouse_name, date_exp),
    by = "session_id"
  ) |>
  relocate(session_id, mouse_name, date_exp, trial) |>
  arrange(session_id, trial)

write_csv(region_activity, file.path(out_dir, "steinmetz_region_activity.csv"))

# ---- Session metadata (for reference / filtering by session) ---------------

write_csv(sessions_raw, file.path(out_dir, "steinmetz_sessions.csv"))

# ---- Data dictionary ---------------------------------------------------------

dict <- c(
  "# Data Dictionary: Steinmetz et al. (2019) Mouse Decision-Making Dataset",
  "",
  "Source: Steinmetz, N.A., Zatka-Haas, P., Carandini, M. & Harris, K.D. (2019).",
  "Distributed coding of choice, action, and engagement across the mouse brain.",
  "Nature, 576, 266-273. CC-BY-4.0 -- cite the paper if used in teaching materials.",
  "",
  "## steinmetz_trials.csv",
  "- `session_id`, `mouse_name`, `date_exp`: session identifiers",
  "- `trial`: trial index within session",
  "- `contrast_left`, `contrast_right`: visual contrast presented on each side (0, 0.25, 0.5, 1)",
  "- `response`: mouse's response (-1 = turned wheel left, 0 = no response, 1 = turned wheel right)",
  "- `feedback_type`: 1 = rewarded, -1 = not rewarded",
  "- `response_time`: seconds from stimulus onset",
  "- `mean_spike_count`: mean spikes per neuron on that trial, across all simultaneously recorded neurons",
  "- `signal_strength`, `correct_response`, `correct`: derived columns framing this as a perceptual-decision/SDT-style problem",
  "",
  "## steinmetz_region_activity.csv",
  "- `session_id`, `mouse_name`, `date_exp`, `trial`: identifiers, as above",
  "- One additional column per recorded brain region (e.g. `VISp`, `CA1`, `MOs` -- names vary by session; see steinmetz_sessions.csv for each session's region list): mean spike count in that region on that trial",
  "- This is a genuine multi-feature, wide matrix -- intended for PCA/dimensionality-reduction teaching, not a simulated stand-in",
  "- Different sessions record from different, only partially overlapping sets of regions; expect NAs when combining sessions in one PCA and decide deliberately how to handle that (a good in-class discussion, not just a technical step)",
  "",
  "## steinmetz_sessions.csv",
  "- `session_id`, `mouse_name`, `date_exp`, `n_trials`, `n_neurons`, `brain_areas` (semicolon-separated list)"
)

writeLines(dict, file.path(out_dir, "steinmetz_dictionary.md"))

message("Done. Wrote 3 CSVs + 1 data dictionary to ", out_dir)
