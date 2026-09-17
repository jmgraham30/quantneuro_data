# Quantitative Neuroscience — Data Curation Plan

Organized by **topic**, since Version A and Version B share most methods. Building a
dataset once for a topic serves both syllabus versions, wherever that topic falls.

| Topic | Real or Simulated | Bio-side plan | Psych-side plan |
|---|---|---|---|
| R/Quarto orientation | Real | Allen Cell Types, small subset | Open Stats Lab, any intro dataset |
| Descriptive stats + wrangling I (filter/select, missing data) | Real, deliberately messy | Allen Cell Types subset, some values dropped | Open Stats Lab dataset with skipped items |
| Probability distributions (normal/binomial/Poisson/exponential) | **Simulated** — needs known ground truth | Spike counts (Poisson), inter-spike intervals (Exponential) | Forced-choice accuracy (Binomial), RT (right-skewed) |
| Confidence intervals / NHST logic | Real | Allen Cell Types, two Cre-lines | Open Stats Lab, two-group study |
| t-tests + effect size | Real | Allen Cell Types, two cell types' firing rate | Open Stats Lab, two-condition study |
| Correlation & regression + joins | Real, split across 2 files | Allen Cell Types ephys file + separate cell-type/layer lookup file | Open Stats Lab data + separate demographics file |
| ANOVA (one-way/factorial) | Real | Allen Cell Types, 3+ Cre-lines or layers | Open Stats Lab, factorial-design study |
| Nonlinear curve fitting (dose-response / psychophysical) | **Simulated** — needs true parameters to check recovery | Dose-response curve (true EC50, Hill slope) | Psychophysical function (true threshold, slope) |
| Chi-square / categorical data | Real | A public rodent outcome dataset (e.g. survival/regeneration) | Open Stats Lab, categorical-outcome study |
| Power / simulation-based | **Simulated by definition** | — | — |
| Repeated measures + pivoting long/wide + mixed models | **Simulated** — need to control the random-effects structure | Calcium-imaging trials, wide format, some missing | RT trials, wide format, some missing |
| Reproducible workflows | Reuse wrangling-week dataset | — | — |
| Reading a real paper (+ multiple comparisons/QRPs) | Real (it's a paper) | Pick an open-access eNeuro paper | Pick an Open Stats Lab paper |
| Logistic regression / classification / SDT | Real preferred; simulate for the SDT "known d′" exercise | Allen Cell Types, cell-type classification from ephys features | Simulated SDT task (known hit/miss rates) + real diagnostic-classification dataset |
| Dimensionality reduction (PCA) | Real | Allen Cell Types, multivariate ephys features | An open Big-Five / cognitive-battery dataset |
| Time-series / signal basics | **Simulated** — cleanest for teaching known frequency content | Simulated LFP with a known oscillation + noise | Simulated or real eye-tracking / skin-conductance trace |
| Computational modeling (LIF neuron / RL choice model) | **Simulated by definition** | — | — |
| Modeling decisions / Bayesian | Simulated, or a real open choice-task dataset | — | — |

**Bottom line: roughly a third of topics need simulation (anything requiring a known ground
truth), and the rest should use real data** from the four sourcing pipelines above.
