# LDhat to find regions of high recombination to then mask for SMC analysis

This directory contains all scripts used run and visualize the sequential markovian coalescent analysis of plasmodium chromosomes


## Requirements

### R packages
- eSMC2 [eSMC2](https://github.com/TPPSellinger/eSMC2)

## Execution Order

1. **Run eSMC2 and SM $\beta$ C**: Both SMC methods ae run on on multihetsep files generated in the previous folder [4_Multihetsep_generation](4_Multihetsep_generation)


---

## Datasets

Both methods were applied to three datasets:

- **Core regions**: filtered for callable, non-repetitive segments  
- **Full chromosome**: includes all callable positions across entire chromosome  
- **Core regions + high recombination regions** : filtered for callable, non-repetitive segments, and regions with $\rho/\theta$ <50, as inferred by LD hat

---

## Model configurations

### eSMC2

**Total hidden states:** 32
**Time segmentation:** 10 segments with 4 hidden states each  
**Mutation rate:** µ = 4.0425e-09 
**Recombination rate:** r = 7.4e-07 (default for fixed-r models)  

Two inference settings are implemented:

1. **Fixed r**
   - Infers only the population scaling constant (χₜ)
   - Keeps r fixed (with r/µ = 183.055)


2. **Free r**
   - Infers both χₜ and r/µ
   - Prior for r/µ = 1, bounds c(2,2) (allowing ±2 orders of magnitude)


---

### SMβC

**Total hidden states:** 40  
**Coalescent parameter:** β-coalescent parameter (α)  
**Mutation rate:** µ = 4.0425e-09
**Recombination rate:** r = 7.4e-07  (default for fixed-r models)  

Three inference settings are included:

1. **Fixed r**
   - Infers only α with fixed r (r/µ = 10)
   - Previous runs showed that r/µ > 100 flattens demography



2. **Free r**
   - Infers both α and r/µ jointly, with prior r/µ = 1 and bounds c(2,2)



3. **Free r (accurate prior)**
   - Infers α and r/µ with accurate simulated prior (ρ/µ from simulations)
   

---

## Folders

#### 1. Final alphas 
 - Final infered alphas for the 'core genome' dataset [1_Final_alphas](1_Final_alphas)
 - Final alphas inferred for the 'core genome + reasonable recombination" dataset

#### 3. Plot SM $\beta$ C results 
 - The SMC demographic and $\alpha$ inference using SMBC in fixed r, free r and free r with an $\alpha$ prior for the full chromosome, and 'core genome' dataset for Maesot [smbc_maesot_plot](SMBC_analyse_new_data_with_reasonable_recomb/smbc_maesot_fullchr_regions_comparison_m4e-09.ipynb) and Binhphuoc Vietnam [smbc_bv_plot](SMBC_analyse_new_data_with_reasonable_recomb/smbc_fullchr_regions_vietrata_comparison_m4e-09.ipynb) datasets 

 - The SMC demographic and $\alpha$ inference using SMBC in fixed r, free r and free r with an $\alpha$ prior for the 'core genome + reasonable recombination' dataset [smbc_regions_maesot](smbc_regions_reasonable_recomb_maesot_comparison_m4e-09)

