#' Prepare the IBL trial-level decision dataset
#'
#' @description
#' Cleans `ibl_trials_raw.csv` (produced by
#' `data-raw/python_prep/export_ibl_trials.py`) into a course-ready dataset
#' framed explicitly as a Signal Detection Theory problem: contrast
#' difference is the signal, and the mouse's choice is the detection
#' response. This is real data serving that role, not a simulated stand-in --
#' a genuine Bio-side parallel to a human perceptual-detection SDT task.
#'
#' @details
#' Source: International Brain Laboratory et al. (2023). A Brain-Wide Map of
#' Neural Activity during Complex Behaviour.
#' https://doi.org/10.1101/2023.07.04.547681
#' Cite the paper if these data are used in teaching materials.
#'
#' Run from the repository root, AFTER running the Python export script:
#'   python data-raw/python_prep/export_ibl_trials.py
#'   Rscript data-raw/prepare_ibl.R
#'
#' @author JMG
#' @date 2026-09-16 (edit to reflect actual run date)
#' @seealso data/ibl/ibl_dictionary.md

library(tidyverse)

raw_path <- file.path("data-raw", "python_prep", "ibl_trials_raw.csv")
out_dir  <- file.path("data", "ibl")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

if (!file.exists(raw_path)) {
  stop(
    "Raw CSV not found at ", raw_path, ". Run the Python export first:\n",
    "  python data-raw/python_prep/export_ibl_trials.py"
  )
}

ibl_trials <- read_csv(raw_path, show_col_types = FALSE) |>
  mutate(
    contrast_left  = replace_na(contrast_left, 0),
    contrast_right = replace_na(contrast_right, 0),
    # SDT framing: "signal" is which side has higher contrast, and how much
    signal_strength = abs(contrast_right - contrast_left),
    signal_side = case_when(
      contrast_right > contrast_left ~ "right",
      contrast_left > contrast_right ~ "left",
      TRUE ~ "none"
    ),
    detected_correctly = as.integer(feedback_type == 1),
    # a no-response trial reads as a missed detection -- real missingness,
    # not injected for the exercise, but doing the same pedagogical job
    responded = as.integer(!is.na(choice) & choice != 0)
  ) |>
  relocate(session_id, trial) |>
  arrange(session_id, trial)

write_csv(ibl_trials, file.path(out_dir, "ibl_trials.csv"))

# ---- Session-level metadata, split out deliberately for a join practice ----

session_meta <- ibl_trials |>
  distinct(session_id) |>
  mutate(
    # session_id from the ONE API is itself the useful identifier; no
    # additional lab/subject metadata is fabricated here -- if a richer
    # session table is wanted later, extend export_ibl_trials.py to pull
    # `one.get_details(session_id)` and add the fields there, not here.
    session_order = row_number()
  )

write_csv(session_meta, file.path(out_dir, "ibl_session_metadata.csv"))

# ---- Data dictionary ---------------------------------------------------------

dict <- c(
  "# Data Dictionary: IBL Trial-Level Decision Dataset",
  "",
  "Source: International Brain Laboratory et al. (2023). A Brain-Wide Map of",
  "Neural Activity during Complex Behaviour. Cite the paper if used in teaching materials.",
  "",
  "## ibl_trials.csv",
  "- `session_id`: IBL session identifier (a UUID-like string)",
  "- `trial`: trial index within session",
  "- `contrast_left`, `contrast_right`: visual contrast on each side",
  "- `choice`: -1 (left), 0 (no response), 1 (right)",
  "- `feedback_type`: 1 = correct/rewarded, -1 = incorrect",
  "- `response_time`: seconds from go-cue to response",
  "- `signal_strength`, `signal_side`: derived SDT-style framing of the contrast difference",
  "- `detected_correctly`: 1 if feedback was positive, else 0",
  "- `responded`: 1 if the mouse made any response (0 = a real missed-detection trial, not simulated)",
  "",
  "## ibl_session_metadata.csv",
  "- `session_id`, `session_order`: join key back to ibl_trials.csv, and an arbitrary ordering",
  "  (kept as a genuinely separate file specifically so students practice the join, as elsewhere in this repo)"
)

writeLines(dict, file.path(out_dir, "ibl_dictionary.md"))

message("Done. Wrote 2 CSVs + 1 data dictionary to ", out_dir)
