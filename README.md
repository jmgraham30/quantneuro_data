# Quantitative Neuroscience — Course Datasets

A curated collection of real and simulated datasets for teaching applied statistics,
data wrangling, and computational modeling to neuroscience students. Wherever
possible, there is a pairing of one example from cellular/systems neuroscience and one from human
cognitive/behavioral neuroscience.


## How this repo is organized

```
quantneuro-data/
├── README.md              <- this file, with the dataset index table below
├── CURATION_PLAN.md        <- full topic-by-topic real-vs-simulated roadmap
├── data-raw/                <- scripts that generate or clean each dataset (source of truth)
│   ├── simulate_distributions.R
│   ├── simulate_repeated_measures.R
│   └── simulate_dose_response.R
├── data/                     <- output CSVs, one subfolder per topic
│   └── <topic>/
│       ├── <topic>_bio.csv
│       ├── <topic>_psych.csv
│       └── <topic>_dictionary.md   <- column-by-column documentation
└── R/                          <- (future) helper functions, once this becomes a package
```

For the simulated datasets, the R code used for generating the data can be found in the scripts 
in the `data-raw/` directory. Everything is fully reproducible and uses a
fixed `set.seed()`. The **ground-truth parameters** used for simulations are in the header comment
— the whole point of simulating is that you know the right answer, so say what it is.

Every real dataset gets a short reference in the table below
and in its `_dictionary.md` file. 

## Dataset index

| Topic | Domain | Type | Dataset | Source / Script |
|---|---|---|---|---|
| Probability distributions | Bio | Simulated | Spike counts (Poisson) & inter-spike intervals (Exponential) | `data-raw/simulate_distributions.R` |
| Probability distributions | Psych | Simulated | Forced-choice accuracy (Binomial) & reaction times (skewed) | `data-raw/simulate_distributions.R` |
| Repeated measures / pivoting / mixed models | Bio | Simulated | Calcium-imaging trials, wide format, with missingness | `data-raw/simulate_repeated_measures.R` |
| Repeated measures / pivoting / mixed models | Psych | Simulated | RT trials, wide format, with missingness | `data-raw/simulate_repeated_measures.R` |
| Nonlinear curve fitting | Bio | Simulated | Dose-response curve (known EC50 & Hill slope) | `data-raw/simulate_dose_response.R` |
| Nonlinear curve fitting | Psych | Simulated | Psychophysical function (known threshold & slope) | `data-raw/simulate_dose_response.R` |
| Descriptive stats, t-tests, ANOVA, regression, PCA, classification | Bio | Real | Allen Institute Cell Types Database | [Allen Cell Types](https://celltypes.brain-map.org/), via [Juavinett's teaching materials](https://github.com/ajuavinett) |
| Descriptive stats, t-tests, ANOVA, regression, reading a paper | Psych | Real | Open Stats Lab datasets (paired with *Psychological Science* articles) | [Open Stats Lab](https://sites.google.com/view/openstatslab/home) |
| Additional psych datasets / lab manual model | Psych | Real | Crump Lab open stats lab manual | [crumplab.com/statisticsLab](https://crumplab.com/statisticsLab/) (CC BY-SA) |
| *(rows to be added as each topic is built — see CURATION_PLAN.md)* | | | | |


