# MalariaGEN Pf7 / TRAC WGS Preprocessing

This repository contains scripts and documentation for preprocessing *Plasmodium falciparum* whole-genome sequencing data from the **MalariaGEN Pf7 data release** and the **TRAC malaria 1052 project**.

---


This workflow processes whole-genome VCF files from **Pf7 / White-Trac-2011** samples across eight Southeast Asian sites, applies quality control filters, and produces a final **haploidized, high-confidence variant dataset** for downstream analysis.

### Preprocessing Pipeline
1. Sample selection by study year and quality control
2. Multiplicity of infection filtering (\(F_{ws} > 0.9\))
3. Chromosome concatenation into genome-wide VCF
4. Variant-level and sample-level quality filtering
5. Allele balance correction
6. Haploidization for downstream analyses

---

## Repository Structure

### 1. Download & Sample Selection
**Folder:** `VCFs/1_Download_Filpf7_full_Chr`

| Script | Description |
|--------|-------------|
| `ftp_download.sh` | Downloads chromosome-level VCFs for TRAC/White-Trac-2011 samples |
| `download_rearrange_md/Data_arrangement.R` | Downloads Pf7 metadata and sampling information |
| `download_rearrange_md/subset_forvcf.R` | Filters samples by \(F_{ws} > 0.9\) |


### 2. Sample Metadata Files
**Folder:** `2_Samplemd_files`

Contains curated sample metadata files for downstream population genetic analyses.

| Subfolder | Description |
|-----------|-------------|
| `Final_Dataset_bydapcclusters_remoutliers` | contains `Allchr_Whitefullfilt_Newdapc_bycluster_ids` and `Allchr_Whitefullfilt_Newdapc_bycluster_md` which has the final metadata and samples taken from the center of DAPC clusters and outlier removal |
| `samples_doublecol_forplink` | Sample lists formatted for PLINK (double-column format) |
| `samples_msmc_esmc` | Sample sets for MSMC/ESMC coalescent analyses, which are the Top 20 confidently assigned inidviduals from the DAPC |
| `Total_dataset_TRACwhite2011` | Complete TRAC/White 2011 dataset final metadata and samples before DAPC subset |

**Usage:** These subfolders provide sample lists tailored to specific analysis pipelines (PLINK, MSMC/ESMC, population structure).



### 3. VCF Processing Pipeline
**Folder:** `VCFs/3_VCF_processing`

#### 3.1 Concatenation & Hard Filters
**Subfolder:** `Subset_Concat_missfilt_scripts`

| Script | Description |
|--------|-------------|
| `concat.sh` | Concatenates chromosome VCFs → genome-wide VCF |
| `filter.sh` | **Hard filters:**<br>- 2011–2012 TRAC 1052 samples<br>- Biallelic SNPs only<br>- `INFO/qcpass`<br>- `VQSLOD > 5` |

#### 3.2 Depth & Allele Balance Filters
**Subfolder:** `depth_maf_ab_ld_scripts`

| Script | Description |
|--------|-------------|
| `soft_filters_dep_allelbal.sh` | **Soft filters** (per [Speciation Genomics protocol](https://speciationgenomics.github.io/filtering_vcfs/)):<br>- Depth & missingness PHRED thresholds<br>- Allele balance correction |

#### 3.3 Final Processing & Haploidization
**Subfolder:** `bcftools_allelebal_remmiss_fixploidy_split`

| Script | Description |
|--------|-------------|
| `fixploidy.sh` | **Haploidization** via `bcftools +fixploidy` |
| `split_bychrom.sh` | (Optional) Split genome VCF back to chromosomes |

#### 3.4 Quality Control
**Subfolder:** `qual_stats`

| File | Description |
|------|-------------|
| `vcf_filter_quality.sh` | Quality statistics computation |
| `qual_stats.ipynb` | Quality visualization notebook |

---

## Software Requirements

```bash
bcftools  # Variant calling & manipulation
vcftools  # VCF filtering & stats
```

---
