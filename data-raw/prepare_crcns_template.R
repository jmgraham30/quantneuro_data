#' CRCNS.org starter template -- NOT a verified pipeline like the other scripts here
#'
#' @description
#' CRCNS.org (crcns.org) is a large, real, well-established repository (NSF-
#' funded since 2008, ~150 datasets: electrophysiology, fMRI, EEG, eye-movement
#' data). It's a genuinely good source, but it's being flagged differently
#' from every other script in this repo, on purpose:
#'
#'   1. Access requires free registration at crcns.org (a login wall, unlike
#'      Allen Cell Types, Open Stats Lab, PhysioNet's open tier, or the
#'      Steinmetz/IBL sources above).
#'   2. There is NO single consistent file format across datasets -- unlike
#'      everything else in this repo, "the CRCNS format" doesn't exist; each
#'      contributing lab packaged their own dataset differently.
#'   3. This script has NOT been verified against a specific real CRCNS
#'      dataset's actual file structure (this was written and tested without
#'      network access to crcns.org). Every other script in this repo was
#'      either fully executed against real/mock data, or built from a
#'      concretely documented, verified access method. This one is a
#'      starting template only.
#'
#' Use this as a skeleton once a SPECIFIC dataset has actually been chosen
#' and downloaded, not as a ready-to-run script.
#'
#' @details
#' To pick a specific dataset: browse https://crcns.org/data-sets (registration
#' required to download, browsing the catalog is free), read that dataset's own
#' README carefully -- it will specify its own file format, which the section
#' below will need to be rewritten around, not just parameterized.
#'
#' Suggested starting candidates, chosen for being frequently reused and
#' well-documented per their CRCNS listing pages (worth confirming their
#' current format directly before committing class time to them):
#'   - A single-unit spike-train dataset from sensory cortex (many exist;
#'     check the "reused more than 10 times" datasets CRCNS itself highlights)
#'   - An eye-movement dataset, if a simpler, more clearly tabular option is
#'     wanted for a first attempt
#'
#' @author JMG
#' @date 2026-09-16 (edit once a specific dataset is chosen and this is rewritten)
#' @seealso https://crcns.org/data-sets

library(tidyverse)

# ---- Step 1: manual step, not automatable here ------------------------------
# Register at crcns.org, choose a dataset, and download it manually (or via
# their documented download mechanism, e.g. the NERSC portal URLs their site
# provides once logged in). Place the raw files in:
raw_dir <- file.path("data-raw", "crcns_raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

# ---- Step 2: THIS SECTION IS A PLACEHOLDER --------------------------------
# Replace the two lines below once the actual file format of the chosen
# dataset is known. Common CRCNS formats include per-trial spike-time text
# files, .mat files (use `R.matlab::readMat()`), or custom binary formats
# documented in that dataset's own README -- there is no way to write this
# correctly in advance without knowing which dataset was chosen.

# raw_data <- read_delim(file.path(raw_dir, "PLACEHOLDER_FILENAME"), ...)
# stop("Replace this template's Step 2 with the actual format of the chosen CRCNS dataset before running.")

# ---- Step 3: once raw_data exists, the rest of the pipeline should look ----
# like every other script in this repo -- tidyverse cleaning, a join if the
# dataset ships metadata separately, a written data dictionary. Sketch:

# out_dir <- file.path("data", "crcns_<dataset_name>")
# dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
#
# cleaned <- raw_data |>
#   # filter/select/mutate as appropriate for the actual columns
#   identity()
#
# write_csv(cleaned, file.path(out_dir, "<dataset_name>.csv"))
#
# dict <- c(
#   "# Data Dictionary: <dataset name>",
#   "",
#   "Source: <full citation>. Access: crcns.org (registration required).",
#   "Cite the dataset's own requested citation -- check its CRCNS page,",
#   "most contributors request this specifically, separate from the paper.",
#   ""
#   # column-by-column documentation here
# )
# writeLines(dict, file.path(out_dir, "<dataset_name>_dictionary.md"))

message(
  "This is a template, not a runnable script. Choose a specific CRCNS ",
  "dataset, confirm its actual file format from its own README, and ",
  "rewrite Steps 2-3 above before this does anything."
)
