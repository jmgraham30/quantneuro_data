#' Simulate a nested pseudoreplication dataset
#'
#' @description
#' Generates one dataset -- neurons nested in animals -- designed to make the
#' pseudoreplication trap visible rather than just describable: pooling all
#' neurons as if each were an independent replicate gives a confidently wrong
#' answer, while the correct unit-of-analysis (the animal) gives the honest
#' one. No psych-side pairing: pseudoreplication is a general design concept
#' about the unit of analysis, not a bio-vs-psych contrast, so one clean
#' illustration serves the teaching point better than a forced pair.
#'
#' Ground truth (instructor answer key):
#'   - True group means: control = 10, treatment = 11 (modest, 1-unit true
#'     difference in firing rate, spikes/sec).
#'   - Between-animal SD = 2.5 (large -- animals vary a lot more than trials
#'     within an animal do, which is what makes this realistic).
#'   - Within-animal (neuron-level) noise SD = 0.6 (small).
#'   - 4 animals per group, 12 neurons recorded per animal (96 rows total,
#'     but only 8 independent replicates).
#'
#' @details
#' The random draw of animal-level means is itself part of the simulation
#' (animals vary around their group's true mean), so the seed below was
#' chosen deliberately, not left at the first draw: it produces a case where
#' the naive, pseudoreplicated test (treating all 96 neurons as independent)
#' comes out strongly "significant" (p < .001) while the correct analysis
#' (averaging to one value per animal first, n = 8) does not (p > .3) --
#' exactly the false-confidence pattern pseudoreplication produces, and the
#' reason the Stats Field Guide's Replication units and pseudoreplication
#' page exists. A different seed would still illustrate inflated significance
#' on average across many simulations, just not this cleanly on any one run.
#'
#' Run from the repository root. Writes 1 CSV plus a data dictionary to
#' `data/pseudoreplication/`.
#'
#' @author JMG
#' @date 2026-10-03
#' @seealso data/pseudoreplication/pseudoreplication_dictionary.md

library(tidyverse)

set.seed(11)

out_dir <- file.path("data", "pseudoreplication")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ---- Ground-truth parameters ------------------------------------------------

n_animals_per_group    <- 4
n_neurons_per_animal   <- 12
true_mean_control      <- 10
true_mean_treatment    <- 11
between_animal_sd      <- 2.5
within_animal_noise_sd <- 0.6

# ---- Animal-level means (the true, correct unit of replication) -----------

animals <- tibble(
  animal_id = paste0("A", seq_len(2 * n_animals_per_group)),
  group = rep(c("control", "treatment"), each = n_animals_per_group)
) |>
  mutate(
    animal_mean = if_else(
      group == "control",
      rnorm(n(), true_mean_control, between_animal_sd),
      rnorm(n(), true_mean_treatment, between_animal_sd)
    )
  )

# ---- Neuron-level rows (what a naive analysis would pool as "n") ----------

nested_pseudoreplication_bio <- animals |>
  reframe(
    neuron_id = paste0(animal_id, "_n", seq_len(n_neurons_per_animal)),
    firing_rate = round(animal_mean + rnorm(n_neurons_per_animal, 0, within_animal_noise_sd), 2),
    .by = c(animal_id, group)
  )

write_csv(nested_pseudoreplication_bio, file.path(out_dir, "nested_pseudoreplication_bio.csv"))

# ---- Sanity check (run interactively before distributing) -----------------

# Naive, pseudoreplicated test -- treats all 96 neurons as independent:
# t.test(firing_rate ~ group, data = nested_pseudoreplication_bio)  # p < .001
#
# Correct test -- one value per animal, the true unit of replication:
# animal_means <- nested_pseudoreplication_bio |> summarize(m = mean(firing_rate), .by = c(animal_id, group))
# t.test(m ~ group, data = animal_means)  # p > .3

# ---- Data dictionary -------------------------------------------------------

dict <- c(
  "# Data Dictionary: Nested Pseudoreplication Dataset",
  "",
  "## nested_pseudoreplication_bio.csv",
  "- `animal_id`: animal identifier (8 animals total, A1-A8)",
  "- `group`: `control` or `treatment` (4 animals per group)",
  "- `neuron_id`: neuron identifier, nested within animal (12 neurons per animal)",
  "- `firing_rate`: simulated firing rate (spikes/sec) for that neuron",
  "",
  "## The pseudoreplication trap this dataset illustrates",
  "There are 96 rows but only 8 independent replicates (the animals) -- the",
  "12 neurons within an animal are correlated with each other, not 12 separate",
  "pieces of evidence about the treatment effect. Averaging to one value per",
  "animal before testing is the simple fix (see the Stats Field Guide's",
  "Replication units and pseudoreplication page); a linear mixed model with a",
  "random intercept for animal is the model-based alternative that uses every",
  "row without pretending neurons are independent.",
  "",
  "## Ground truth (instructor answer key)",
  paste0("- True group means: control = ", true_mean_control,
         ", treatment = ", true_mean_treatment, " spikes/sec"),
  paste0("- Between-animal SD = ", between_animal_sd,
         "; within-animal (neuron-level) noise SD = ", within_animal_noise_sd),
  paste0(n_animals_per_group, " animals per group, ",
         n_neurons_per_animal, " neurons per animal."),
  "Naive test on all 96 neurons: p < .001. Correct test on the 8 animal means: p > .3."
)

writeLines(dict, file.path(out_dir, "pseudoreplication_dictionary.md"))

message("Done. Wrote 1 CSV + 1 data dictionary to ", out_dir)
