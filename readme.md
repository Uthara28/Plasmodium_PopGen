
# Signatures of Multiple‑Merger Coalescence in Populations of *Plasmodium falciparum* Using SMC Methods

This repository contains data, scripts, and results for a study investigating **multiple‑merger coalescent models (MMCs)** in the population genetics of ***Plasmodium falciparum***. 


## Repository structure

The project is organized into the following folders:

### `Figures/`
- Final and intermediate figures 

### `Final analysis/`
- Main analysis scripts (R/Python) 

### `VCFs/`
- Scripts and documentation for downloading and preprocessing *P. falciparum* variant calls in **VCF** format (e.g., from public datasets such as Pf7/Pf8 or MalariaGEN).
- Typical contents:
  - Links and commands to download VCFs 
  - Quality‑filtering scripts using `bcftools`, `vcftools`, or similar tools.
  - Scripts to subset samples by \F_{ws} and year.
