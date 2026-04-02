# README: Complete multihetsep Pipeline for MSMC2/eSMC2/SMβC (Plasmodium falciparum Pf7)

## Overview
This repository provides a pipeline to generate `multihetsep` input files for SMC-based demographic inference (MSMC2, eSMC2, SMβC) from Plasmodium falciparum Pf7 BAM files. The pipeline is modified from Miles Anderson's HaplotypeCaller protocol.
- In the final study we use processes 4 high-quality samples per subpopulation (Maesot: PD0524-C, PD0477-C, PD0529-C, PD0543-C; North Cambodia-Vietnam: PH0879-C, PV0311-C, PV0333-C, PV0254-C) across all 14 Pf3D7 chromosomes.

**Key features:**
- Generates both **full chromosome** and **core regions** datasets (excluding subtelomeres, centromeres, hypervariable regions)
- Handles Plasmodium-specific challenges (haploid genome, MOI-induced het calls, depth filtering)
- Produces eSMC2/SMβC-ready files that can be plugged into `Get_real_data()` 


**Output format** (4 columns): `chromosome position homozygous_distance phased_alleles`