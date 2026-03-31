# LDhat to find regions of high recombination to then mask for SMC analysis

This directory contains all scripts used to generate data for and visualize LDhat results, to filter regions that have high $\rho/\theta_w$, and remove these from the callable sites mask during SMC multihetsepfile data preparation. This is to create the dataset hereafter called 'Core genome + reasonable recombination' dataset, which is created by masking the both the uncallable subtelomeric and hypervariable repeat regions and the regions with high $\rho/theta_w$ > 50. 

## Overview of Analyses

**Generate data → run LDhat → visualize ρ/θw**

## Requirements

### Python packages
- scikit-allel

### External software
- [LDhat](https://ldhat.sourceforge.net/LDhat1.0/LDhat1.0.shtml)

## Execution Order

1. **Generate data** for LDhat format (with problematic regions masked):  
  
   

2. **Run LDhat** command:  

## generate lk file for 50 samples 

```bash
 ./lkgen -lk <premade lk file from ldhat github> -nseq <int>
```

  [new_lk.txt](new_lk.txt)

## Run LDhat interval command
```bash
./interval -seq masked_sites.sites -loc masked_sites.locs -lk lk_n50_t0.001.txt -its 2000000 -bpen 5 -samp 2000 -prefix subpop_chrom_14

```
  **Summarize with stat**:
```bash
./stat -rate rho_estimates_rates.txt -loc masked_sites.locs -summary -burn 200
```

3. **Visualize ρ/θ**: Calculate θw using scikit-allel, and divide LD hat inferred $\rho$ by the $\theta_w$ to get regions with high $\rho/\theta_w$, to ensure accurate downstream SMC inference. 

## References

A. Auton and G. McVean. "Recombination rate estimation in the presence of hotspots." *Genome Res.* (2007):epub.