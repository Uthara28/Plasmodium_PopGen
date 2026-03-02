#!/bin/bash

bcftools view \
    --include 'FILTER="PASS" && N_ALT=1 && TYPE="snp" && VQSLOD>5.0' \
    --samples-file /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/Samplemd_files/Allchr_70IDs_newpops.txt \
    -O z \
    /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/pf7_full_Chr/Pf3D7_14_v3.pf7.vcf.gz \
| bcftools filter -e 'F_MISSING > 0.2 || GT=="het"' -Oz -o Pf3D7_0.2miss_qcpass_GTrem_chr14_3pops.vcf.gz

bcftools index Pf3D7_0.2miss_qcpass_GTrem_chr01_3pops.vcf.gz


bcftools filter /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/vcg.gz.r3/Pf3D7_05_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz -e 'F_MISSING > 0.2 || GT=="het"' -Oz -o Pf3D7_0miss_qcpass_GTrem_Newdapc_3pops.vcf.gz

bcftools view -O z /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/vcg.gz.r3/Pf3D7_05_ctv_qcpass_GTfil_vqslo5_0.miss.vcf.gz --samples-file /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/Samplemd_files/White_1052_ctv_471inds_sampleIds.txt  -o Pf3D7_0.miss.chr05_White_ctv.vcf.gz



# Run the BCFtools filter command
bcftools filter $input_vcf \
-e 'F_MISSING > 0.2 || GT=="het"' \  # Filter expression: exclude sites with more than 20% missing data or heterozygous genotype
-Oz \  # Output in compressed VCF format
-o $output_vcf  # Output file
