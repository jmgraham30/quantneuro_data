# Data Dictionary: Nested Pseudoreplication Dataset

## nested_pseudoreplication_bio.csv
- `animal_id`: animal identifier (8 animals total, A1-A8)
- `group`: `control` or `treatment` (4 animals per group)
- `neuron_id`: neuron identifier, nested within animal (12 neurons per animal)
- `firing_rate`: simulated firing rate (spikes/sec) for that neuron

## The pseudoreplication trap this dataset illustrates
There are 96 rows but only 8 independent replicates (the animals) -- the
12 neurons within an animal are correlated with each other, not 12 separate
pieces of evidence about the treatment effect. Averaging to one value per
animal before testing is the simple fix (see the Stats Field Guide's
Replication units and pseudoreplication page); a linear mixed model with a
random intercept for animal is the model-based alternative that uses every
row without pretending neurons are independent.

## Ground truth (instructor answer key)
- True group means: control = 10, treatment = 11 spikes/sec
- Between-animal SD = 2.5; within-animal (neuron-level) noise SD = 0.6
4 animals per group, 12 neurons per animal.
Naive test on all 96 neurons: p < .001. Correct test on the 8 animal means: p > .3.
