#!/bin/bash
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH --time=48:00:00
#SBATCH -J bcftools.sh

vcf_dir="/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/Cam.Thai.Viet.redo.gz"
output_dir="/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs"

# Input VCF file

#cambodia,thailand vietnam
vcf_file_05_ctv="$vcf_dir/Pf3D7_05_cam.thai.viet_snp_qcpass_GT_filtered.vcf.gz"
vcf_file_10_ctv="$vcf_dir/Pf3D7_10_cam.thai.viet_snp_qcpass_GTfiltered.vcf.gz"
vcf_file_13_ctv="$vcf_dir/Pf3D7_13_cam.thai.viet_snp_qcpass_GTfiltered.vcf.gz"

#all of southeast asia
vcf_file_05_sea="$vcf_dir/Pf3D7_05_all.sea.pops_snps_qcpass_GTfiltered.vcf.gz"
vcf_file_10_sea="$vcf_dir/Pf3D7_10_all.sea.pops_snps_qcpass_GTfiltered.vcf.gz"
vcf_file_13_sea="$vcf_dir/Pf3D7_13_all.sea.pops_snps_qcpass_GTfiltered.vcf.gz"


# Output directory for the index file
output_index_dir="$output_dir/index"

# Create the output directory 
#mkdir -p "$output_index_dir"

# Run bcftools index with the output directory specified

#cambodia, vietnam, thailand
bcftools index -t "$vcf_file_05" -o "$output_index_dir/Pf3D7_05_cam.thai.viet.GTfiltered.vcf.gz.csi"
bcftools index -t "$vcf_file_10" -o "$output_index_dir/Pf3D7_10_cam.thai.viet.GTfiltered.vcf.gz.csi"
bcftools index -t "$vcf_file_13" -o "$output_index_dir/Pf3D7_13_cam.thai.viet.GTfiltered.vcf.gz.csi"


#For southeast asia
bcftools index -t "$vcf_file_05" -o "$output_index_dir/Pf3D7_05_all.sea.pops.GTfiltered.vcf.gz.csi"
bcftools index -t "$vcf_file_10" -o "$output_index_dir/Pf3D7_10_all.sea.pops.GTfiltered.vcf.gz.csi"
bcftools index -t "$vcf_file_13" -o "$output_index_dir/Pf3D7_13_all.sea.pops.GTfiltered.vcf.gz.csi"
