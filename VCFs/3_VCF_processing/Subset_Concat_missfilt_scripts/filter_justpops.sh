#!/bin/bash
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH -J bcft_05.sh
#SBATCH --nodelist=node12

bcftools view \
    --include 'FILTER="PASS" && N_ALT=1 && TYPE="snp" && VQSLOD>5.0' \
    --samples-file /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/Samplemd_files/White_1052_ctv_471inds_sampleIds.txt\
    -Oz -o Pf3D7_Nofilt_qcpass_chr04_white.vcf.gz \
    /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/pf7_full_Chr/Pf3D7_04_v3.pf7.vcf.gz
