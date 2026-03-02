#!/bin/bash
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH -J concat
#SBATCH --nodelist=node12

cd /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/vcg.gz.r3

# Concatenate VCF files
bcftools concat Pf3D7_01_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz Pf3D7_02_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz Pf3D7_03_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz Pf3D7_04_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz Pf3D7_05_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz \
        Pf3D7_06_ctv_qcpass_GTfil_vqslo5_0.miss.vcf Pf3D7_07_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz Pf3D7_08_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz Pf3D7_02_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz Pf3D7_10_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz \
        Pf3D7_11_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz Pf3D7_12_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz Pf3D7_13_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz Pf3D7_14_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz 
        -Oz -o Pf3D7_ctv_0.miss_full_concatenated.vcf.gz

# Index the concatenated VCF file
bcftools index Pf3D7_ctv_qcpass_GTfil_vqslo5_0.miss.concatenated.vcf.gz

