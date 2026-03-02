# Population Structure Analyses

This directory contains all scripts used to investigate population structure using
multivariate, model-based, and phylogenetic distance-based approaches.

## Overview of Analyses

1. **Discriminant Analysis of Principal Components (DAPC)**
   - DAPC analysis performed based on:
     - Ward’s clustering priors
     - Sampling location priors
   - Sample selection:
     - Outlier filtering based on Euclidean distance

2. **ADMIXTURE analysis (K = 1–10)**
   - Multiple iterations per K
   - Consensus visualization using *pong*

3. **Phylogenetic distance-based methods**
   - Neighbor-joining tree (Prevosti distance)
   - Bootstrapped dendrogram (Nei’s distance)

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
2. Filter confidently assigned individuals (`03`)
3. Run ADMIXTURE (`04`)
4. Visualise ADMIXTURE results (`05`)
5. Build Neighbour joining trees (`06`, `07`) + Visualise tree results

