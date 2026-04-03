#!/bin/bash

bcftools view \
    --include 'FILTER="PASS" && N_ALT=1 && TYPE="snp" && VQSLOD>5.0' \
    --samples-file /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/Samplemd_files/Total_dataset_TRACwhite2011/White_1052_ctv_471inds_sampleIds.txt \
    -O z \
    /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/pf7_full_Chr/Pf3D7_14_v3.pf7.vcf.gz \
| bcftools filter -e 'F_MISSING > 0.2 || GT=="het"' -Oz -o Pf3D7_0.2miss_qcpass_GTrem_chr14_3pops.vcf.gz

bcftools index Pf3D7_0.2miss_qcpass_GTrem_chr01_3pops.vcf.gz

