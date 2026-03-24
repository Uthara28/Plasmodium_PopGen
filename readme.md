
# Signatures of Multiple‑Merger Coalescence in Populations of *Plasmodium falciparum* Using SMC Methods

This repository contains data, scripts, and results for a study investigating **multiple‑merger coalescent models (MMCs)** in the population genetics of ***Plasmodium falciparum***. The project explores how **multiple‑merger coalescent processes** differ from the standard **Kingman coalescent** in shaping the parasite’s **genetic diversity** and **transmission dynamics**, using **SMC‑based inference methods**.

## Overview

The study aims to:
- Detect signatures of multiple‑merger coalescence (e.g., skewed offspring distributions, superspreading‑like transmission) in global *P. falciparum* populations.
- Compare inferred genealogies, effective population size trajectories, and site‑frequency spectra under Kingman vs. MMC models (e.g., Beta‑coalescent parametrizations).
- Relate MMC signatures to epidemiological and ecological factors such as transmission intensity, host‑population structure, and drug‑pressure regimes.

## Repository structure

The project is organized into the following folders:

### `Figures/`
- Final and intermediate figures (e.g., inferred Ne(t) trajectories, site‑frequency spectra, tree‑shape statistics, and model‑comparison plots).
- Output files in common formats (e.g., `.pdf`, `.png`, `.svg`).

### `Final analysis/`
- Main analysis scripts (e.g., R/Python) that:
  - Run SMC and MMC inference pipelines.
  - Process output from phylodyn or related SMC/ARG‑based tools.
  - Compute summary statistics and tables.
- Typical analyses include:
  - Demographic‑history inference under Kingman and Beta‑coalescent models.
  - MCMC or hybrid estimation of MMC parameters (e.g., α) and effective population size trajectories.
  - Comparison of model fits (e.g., via SFS‑based tests or likelihood/deviance metrics).

### `download VCFs/`
- Scripts and documentation for downloading and preprocessing *P. falciparum* variant calls in **VCF** format (e.g., from public datasets such as Pf7/Pf8 or MalariaGEN).
- Typical contents:
  - Links and commands to download VCFs or gVCFs.
  - Quality‑filtering scripts using `bcftools`, `vcftools`, or similar tools.
  - Scripts to subset samples by geography, drug‑resistance markers, or other metadata.

## Usage

1. Clone the repository:
   ```bash
   git clone <repository-url>
