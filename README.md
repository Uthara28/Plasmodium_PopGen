# Project Overview

## SMC-Based Parameter Inference from *Plasmodium falciparum* Data

We infer demographic and coalescent parameters from whole-genome sequencing data of *Plasmodium falciparum* using a Sequentially Markovian Coalescent (SMC)–based framework. Given the parasite’s extreme reproductive variance and recurrent transmission bottlenecks, standard Kingman-based SMC methods may be inappropriate.

To address this, we apply **SMβC**, an extension of MSMC that accommodates multiple-merger genealogies under the β-coalescent. Implemented via the R package **eSMC2**, SMβC models the distribution of first coalescence events along the genome while allowing for simultaneous lineage mergers.

The primary parameter of interest is the β-coalescent parameter **α**, where lower values indicate more frequent and larger multiple-merger events. Estimates of α, alongside effective population size trajectories, are used to characterize sweepstake-like reproduction and its impact on genome evolution.

The robustness of the method, when applied to genomes matching the size and recombination and mutation rates of *Plasmodium falciparum*, is assessed by applying the SMC framework to simulated data.


## Repository Structure

The repository is organized into three main folders:

1. **Figures**  
   Contains all result visualizations as `.png` files.

2. **Data Processing**  
   Includes Bash scripts and Jupyter notebooks used for data download, preprocessing, and exploratory visualization.

3. **Final Analysis**  
   Contains six subfolders covering the complete analysis workflow, including:
   - Structure analysis for sample selection  
   - Sample selection for SMC-based inference  
   - LDhat analysis to identify low-recombination regions for subsetting  
   - Simulation-based validation of SMC methods  
   - Scripts to generate the `multihetsepfile` required for SMC execution  
   - Scripts for SMC runs and final visualization of inferred results# Project Overview

## SMC-Based Parameter Inference from *Plasmodium falciparum* Data

We infer demographic and coalescent parameters from whole-genome sequencing data of *Plasmodium falciparum* using a Sequentially Markovian Coalescent (SMC)–based framework. Given the parasite’s extreme reproductive variance and recurrent transmission bottlenecks, standard Kingman-based SMC methods may be inappropriate.

To address this, we apply **SMβC**, an extension of MSMC that accommodates multiple-merger genealogies under the β-coalescent. Implemented via the R package **eSMC2**, SMβC models the distribution of first coalescence events along the genome while allowing for simultaneous lineage mergers.

The primary parameter of interest is the β-coalescent parameter **α**, where lower values indicate more frequent and larger multiple-merger events. Estimates of α, alongside effective population size trajectories, are used to characterize sweepstake-like reproduction and its impact on genome evolution.

The robustness of the method, when applied to genomes matching the size and recombination and mutation rates of *Plasmodium falciparum*, is assessed by applying the SMC framework to simulated data.


## Repository Structure

The repository is organized into three main folders:

1. **Figures**  
   Contains all result visualizations as `.png` files.

2. **Data Processing**  
   Includes Bash scripts and Jupyter notebooks used for data download, preprocessing, and exploratory visualization.

3. **Final Analysis**  
   Contains six subfolders covering the complete analysis workflow, including:
   - Structure analysis for sample selection  
   - Sample selection for SMC-based inference  
   - LDhat analysis to identify low-recombination regions for subsetting  
   - Simulation-based validation of SMC methods  
   - Scripts to generate the `multihetsepfile` required for SMC execution  
   - Scripts for SMC runs and final visualization of inferred results# Project Overview

## SMC-Based Parameter Inference from *Plasmodium falciparum* Data

We infer demographic and coalescent parameters from whole-genome sequencing data of *Plasmodium falciparum* using a Sequentially Markovian Coalescent (SMC)–based framework. Given the parasite’s extreme reproductive variance and recurrent transmission bottlenecks, standard Kingman-based SMC methods may be inappropriate.

To address this, we apply **SMβC**, an extension of MSMC that accommodates multiple-merger genealogies under the β-coalescent. Implemented via the R package **eSMC2**, SMβC models the distribution of first coalescence events along the genome while allowing for simultaneous lineage mergers.

The primary parameter of interest is the β-coalescent parameter **α**, where lower values indicate more frequent and larger multiple-merger events. Estimates of α, alongside effective population size trajectories, are used to characterize sweepstake-like reproduction and its impact on genome evolution.

The robustness of the method, when applied to genomes matching the size and recombination and mutation rates of *Plasmodium falciparum*, is assessed by applying the SMC framework to simulated data.


## Repository Structure

The repository is organized into three main folders:

1. **Figures**  
   Contains all result visualizations as `.png` files.

2. **Data Processing**  
   Includes Bash scripts and Jupyter notebooks used for data download, preprocessing, and exploratory visualization.

3. **Final Analysis**  
   Contains six subfolders covering the complete analysis workflow, including:
   - Structure analysis for sample selection  
   - Sample selection for SMC-based inference  
   - LDhat analysis to identify low-recombination regions for subsetting  
   - Simulation-based validation of SMC methods  
   - Scripts to generate the `multihetsepfile` required for SMC execution  
   - Scripts for SMC runs and final visualization of inferred results