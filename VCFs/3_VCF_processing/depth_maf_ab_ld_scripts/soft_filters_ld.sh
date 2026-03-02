#!/bin/bash

# Check if input VCF file is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input.vcf.gz> <output_directory>"
    exit 1
fi

input_vcf=$1
out_dir=$2
base_name=$(basename "$input_vcf" .vcf.gz)
unzipped_vcf="${out_dir}/${base_name}.vcf"  # Define the path for the unzipped VCF

# Ensure the output directory exists
mkdir -p "$out_dir"

# Common flags for PLINK commands
common_flags="--double-id --allow-extra-chr --no-sex --chr-set 14"

# Step 1: Unzip the VCF file
gunzip -c "$input_vcf" > "$unzipped_vcf"
if [ $? -ne 0 ]; then
    echo "Error: Failed to unzip $input_vcf"
    exit 1
fi

# Step 2: Convert unzipped VCF to PLINK format
plink --vcf "$unzipped_vcf" --make-bed --out "${out_dir}/${base_name}_data" $common_flags --memory 10000

# Check if PLINK conversion succeeded
if [ $? -ne 0 ] || [ ! -f "${out_dir}/${base_name}_data.bed" ]; then
    echo "Error: PLINK failed to convert VCF to PLINK format."
    exit 1
fi

# Step 3: Perform LD pruning
plink --bfile "${out_dir}/${base_name}_data" --indep-pairwise 50 5 0.5 --out "${out_dir}/${base_name}_pruned" $common_flags

# Step 4: Extract the pruned SNPs
plink --bfile "${out_dir}/${base_name}_data" --extract "${out_dir}/${base_name}_pruned.prune.in" --make-bed --out "${out_dir}/${base_name}_pruned_data" $common_flags

# Step 5: Convert the pruned dataset back to VCF
plink --bfile "${out_dir}/${base_name}_pruned_data" --recode vcf --out "${out_dir}/${base_name}_pruned_output" $common_flags

echo "LD pruning complete. Pruned VCF file: ${out_dir}/${base_name}_pruned_output.vcf"
