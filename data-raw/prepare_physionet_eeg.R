#' Prepare the PhysioNet EEG Motor Movement/Imagery dataset (time-series week)
#'
#' @description
#' Unlike the Steinmetz/IBL scripts in this folder, this one needs NO Python
#' step: PhysioNet's open-access files download directly over plain HTTPS,
#' and the one EDF-specific piece (reading the European Data Format signal
#' files) is handled by the CRAN package `edfReader`. Everything else is
#' ordinary tidyverse.
#'
#' This is real human EEG, intended as the Psych-side, real-data option for
#' the time-series week -- a genuine alternative or companion to the
#' currently-simulated Psych time-series dataset (see
#' `simulate_diagnostic_failures.R`'s neighbors), not a replacement for the
#' Bio-side simulated LFP, which stays simulated for now (no equally simple
#' real animal LFP source has been vetted yet -- see CURATION_PLAN.md).
#'
#' @details
#' Source: Schalk, G., McFarland, D.J., Hinterberger, T., Birbaumer, N. &
#' Wolpaw, J.R. (2004). BCI2000: a general-purpose brain-computer interface
#' (BCI) system. IEEE Transactions on Biomedical Engineering, 51(6), 1034-1043.
#' Data: Goldberger, A.L. et al. (2000). PhysioBank, PhysioToolkit, and
#' PhysioNet. Circulation, 101(23), e215-e220.
#' https://physionet.org/content/eegmmidb/1.0.0/
#' Open Data Commons Open Database License (ODbL) -- cite both papers above
#' if these data are used in teaching materials.
#'
#' One subject, one run is plenty for teaching (64 channels is already a lot
#' to look at); this script defaults to subject 1, run 1 (eyes-open baseline)
#' but the SUBJECT/RUN constants below can be changed for a different subject
#' or task run.
#'
#' Requires the `edfReader` package: install.packages("edfReader")
#' Run from the repository root:
#'   Rscript data-raw/prepare_physionet_eeg.R
#'
#' @author JMG
#' @date 2026-09-16 (edit to reflect actual run date)
#' @seealso data/physionet_eeg/physionet_eeg_dictionary.md

library(tidyverse)
library(edfReader)

SUBJECT <- "S001"
RUN     <- "R01"  # R01 = baseline, eyes open

raw_dir <- file.path("data-raw", "physionet_eeg")
out_dir <- file.path("data", "physionet_eeg")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

edf_url <- str_glue(
  "https://physionet.org/files/eegmmidb/1.0.0/{SUBJECT}/{SUBJECT}{RUN}.edf"
)
edf_path <- file.path(raw_dir, str_glue("{SUBJECT}{RUN}.edf"))

if (!file.exists(edf_path)) {
  message("Downloading ", edf_url)
  download.file(edf_url, edf_path, mode = "wb", quiet = TRUE)
}

# ---- Read the EDF file -------------------------------------------------------

edf_header  <- readEdfHeader(edf_path)
edf_signals <- readEdfSignals(edf_header)

# `edf_signals` is a list, one element per recorded channel; each element
# has (at minimum) `$signal` (the numeric trace) and `$sRate` (Hz). Channel
# names come from `edf_header$sHeaders$label`. Inspect with str(edf_signals[[1]])
# if a different EDF file has a different structure -- this is the one place
# in the pipeline that's genuinely format-dependent rather than guaranteed
# tidyverse-portable, precisely because it's the file's native (non-tidy) form.

channel_labels <- edf_header$sHeaders$label
sample_rate <- edf_signals[[1]]$sRate

eeg_long <- map2(edf_signals, channel_labels, function(sig, label) {
  tibble(
    channel = label,
    sample = seq_along(sig$signal),
    time_sec = (seq_along(sig$signal) - 1) / sample_rate,
    voltage = sig$signal
  )
}) |>
  list_rbind()

# Full-resolution, all-channel EEG is large; for course use, keep a modest
# time window (first 10 seconds) and a handful of channels rather than
# writing the entire recording, and say so explicitly in the dictionary.
eeg_subset <- eeg_long |>
  filter(time_sec <= 10) |>
  filter(channel %in% head(unique(channel), 8))

write_csv(eeg_subset, file.path(out_dir, "physionet_eeg_subset_psych.csv"))

# ---- Data dictionary ---------------------------------------------------------

dict <- c(
  "# Data Dictionary: PhysioNet EEG Motor Movement/Imagery Dataset (subset)",
  "",
  "Source: Schalk, G. et al. (2004), IEEE Trans. Biomed. Eng. Data via",
  "Goldberger, A.L. et al. (2000), Circulation (PhysioNet). ODbL license --",
  "cite both papers if used in teaching materials.",
  "https://physionet.org/content/eegmmidb/1.0.0/",
  "",
  "## physionet_eeg_subset_psych.csv",
  str_glue("- Subject {SUBJECT}, run {RUN} (baseline, eyes open); first 10 seconds only, first 8 of 64 channels only -- a deliberately small teaching slice, not the full recording"),
  "- `channel`: EEG electrode label (10-10 system, e.g. Fc5, Fc1, Fc6...)",
  "- `sample`: sample index within this slice",
  str_glue("- `time_sec`: time in seconds from recording start (sample rate = {sample_rate} Hz)"),
  "- `voltage`: EEG signal amplitude",
  "",
  "## Suggested use",
  "This is real, unfiltered human EEG -- expect line noise and artifacts, which is itself a legitimate teaching point for the time-series week (real signals are messier than the simulated LFP used elsewhere in this repo). A simple moving-average or bandpass filter, applied and then visually compared to the raw trace, makes a good in-class exercise."
)

writeLines(dict, file.path(out_dir, "physionet_eeg_dictionary.md"))

message("Done. Wrote 1 CSV + 1 data dictionary to ", out_dir)
