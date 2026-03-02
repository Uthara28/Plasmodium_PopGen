#!/bin/bash

# Check if input and output directory are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <output_directory> <depth_filt_vcf>"
    exit 1
fi

# Input and output files
              # Input VCF (gzipped)
VCF_OUT_DIR=$1        # Output directory for filtered VCFs
depth_filt_vcf=$2
# Ensure the output directory exists
mkdir -p "$VCF_OUT_DIR"

# Set filters
QUAL=30 #Set phred scrore minimum threhold
MIN_DEPTH=10 # mean - 3x  of mean variant depth
MAX_DEPTH=83.52 # mean + 3x  standard deviation of the mean variant depth
MISS=0.9 # Max missingness allowed for variants (10%).
          # This is set as the counterintuitive inverse of the % missingness you want to keep in vcftools

#Step 1: Remove individuals sequenced at very high or very low depths: 10x - 125x

SAMP_FILT_VCF="$depth_filt_vcf"


VCF_OUT="${VCF_OUT_DIR}/Pf3D7_dep10_90x_qcpass_White_Allchr_combined_final_filtered.vcf.gz"

vcftools --gzvcf "$SAMP_FILT_VCF" \
         --remove-indels \
         --minQ "$QUAL" \
         --min-meanDP "$MIN_DEPTH" \
         --max-meanDP "$MAX_DEPTH" \
         --max-missing "$MISS" \
         --recode \
         --stdout | bgzip > "$VCF_OUT"

# Check if filtering by depth, quality, and missingness succeeded
if [ $? -ne 0 ]; then
    echo "Error: vcftools filtering failed."
    exit 1
fi

# Step 3: Index the final VCF file
bcftools index "$VCF_OUT"

# Check if indexing succeeded
if [ $? -ne 0 ]; then
    echo "Error: Indexing of the VCF file failed."
    exit 1
fi

echo "Filtering completed. Final output saved to $VCF_OUT."
echo "Indexing completed for $VCF_OUT."
