# Population Structure Analyses

This directory contains all scripts used to investigate population structure using
multivariate, model-based, and phylogenetic distance-based approaches.

## Overview of Analyses

### Folders 

1. **Discriminant Analysis of Principal Components (DAPC)**
   - DAPC analysis performed based on:
     - Ward’s clustering priors
     - Sampling location priors
   - Sample selection:
     - Outlier filtering based on Euclidean distance
   [DAPC](DAPC)

2. **ADMIXTURE analysis (K = 1–10)**
   - Multiple iterations per K
   - Consensus visualization using *pong*
    [Admixture](Admixture)
3. **Phylogenetic distance-based methods**
   - Neighbor-joining tree (Prevosti distance)
   - Bootstrapped dendrogram (Nei’s distance)
    [Nj_tree](Nj_tree)
## Requirements

### R packages
- adegenet
- ape
- poppr
- tidyverse
- vcfR
- purrr

### External software
- ADMIXTURE
- pong
- PLINK


## Execution Order

1. Run DAPC analyses (`01`, `02`)
2. Run ADMIXTURE (`04`)
3. Visualise ADMIXTURE results (`05`)
4. Build Neighbour joining trees (`06`, `07`) + Visualise tree results
5. Filter confidently assigned individuals [dapc_plot.ipynb](dapc_plot.ipynb)
