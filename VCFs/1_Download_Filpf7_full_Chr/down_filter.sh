#!/bin/bash

cd /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/pf7_full_Chr
wget ftp://ngs.sanger.ac.uk/production/malaria/Resource/34/Pf7_vcf/Pf3D7_01_v3.pf7.vcf.gz
bcftools view \
    --include 'FILTER="PASS" && N_ALT=1 && TYPE="snp" && VQSLOD>5.0' \
    --samples-file /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/Samplemd_files/Total_dataset_TRACwhite2011/White_1052_ctv_471inds_sampleIds.txt\
    -Oz -o Pf3D7_Nofilt_qcpass_chr01_white.vcf.gz \
    Pf3D7_01_v3.pf7.vcf.gz
