# MalariaGEN Pf7 / TRAC WGS Preprocessing

This repository contains scripts and documentation for preprocessing *Plasmodium falciparum* whole-genome sequencing data from the MalariaGEN Pf7 data release and the TRAC malaria 1052 project.

## Project overview

This workflow processes whole-genome VCF files from Pf7 / White-Trac-2011 samples, applies quality control filters, and prepares a final haploidized, high-confidence variant dataset for downstream analysis. These samples span eight sampling sites, Maesot, Ranong, Sisakhet
from Thailand, Pailin, Preahvihear, Pursat, from Cambodia and Binhphuoc from Vitenam in Southeast Asia.

The preprocessing steps include:

- Sample selection by study year and quality control.
- Filtering for multiplicity of infection using \(F_{ws}\).
- Chromosome concatenation into a full genome VCF.
- Variant-level and sample-level quality filtering.
- Allele balance correction.
- Haploidization of genotypes for downstream analysis.

## Data sources

- MalariaGEN Pf7 data release.
- TRAC malaria 1052 project.
- White-Trac-2011 study samples.


## Script locations

All preprocessing scripts are stored in the `scripts/` directory.

###  Download VCFs: `VCFs/1_Download_Filpf7_full_Chr/ftp_download.sh`
Downloads chromosome-level VCF files from the Pf7 repository for the selected TRAC / White-Trac-2011 samples.


### Download metadata: `scripts/01_download_vcfs.sh`
Downloads chromosome-level VCF files from the Pf7 repository for the selected TRAC / White-Trac-2011 samples.


### `scripts/02_concat_chromosomes.sh`
Concatenates chromosome-specific VCFs into a single genome-wide VCF.

### `scripts/03_sample_filtering.sh`
Filters samples by:

- sampling year: 2011–2012, TRAC 1052 project
- biallelic SNPs only,
- `INFO/qcpass`,
- `VQSLOD > 5`,
- \(F_{ws} > 0.9\).

### Folder name: [depth_maf_ab_ld_scripts](/VCFs/3_VCF_processing/depth_maf_ab_ld_scripts)

Applies hard filters to retain high-confidence variants, including:

- depth and missingness thresholds, [scripts/04_variant_qc.sh]()
- phred quality filtering.

following the protocol described by [speciationgenomics.github.io](https://speciationgenomics.github.io/filtering_vcfs/)

### Folder name: [bcftools_allelebal_remmiss_fixploidy_split](/VCFs/3_VCF_processing/bcftools_allelebal_remmiss_fixploidy_split)

### `scripts/05_allele_balance_filtering.sh` [Allele_bal.sh](/home/usriniva/Desktop/masters/plasmodium/VCFs/3_VCF_processing/bcftools_allelebal_remmiss_fixploidy_split/Allele_bal.sh)

Removes low-confidence genotype calls based on allele balance and converts poorly supported heterozygous calls to missing or corrected homozygous states as appropriate.

### `scripts/06_haploidize.sh` [fixploidy.sh](/VCFs/3_VCF_processing/bcftools_allelebal_remmiss_fixploidy_split/fixploidy.sh)

Runs haploidization using `bcftools +fixploidy` for downstream haploid analyses. 

### Folder name: [VCFs/3_VCF_processing/qual_stats](/VCFs/3_VCF_processing/qual_stats)
- Apply quality stats checks: `/qual_stats/vcf_filter_quality.sh`
- Visualize: `/qual_stats.ipynb`

Generates summary tables and plots of sample and variant retention after filtering.


## Software requirements

The preprocessing workflow assumes the following tools are available:

- `bcftools`
- `vcftools`
