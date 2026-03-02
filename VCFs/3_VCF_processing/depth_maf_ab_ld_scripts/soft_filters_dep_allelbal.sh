#!/bin/bash

# Check if input and output directory are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_vcf.gz> <output_directory>"
    exit 1
fi

# Input and output files
VCF_IN=$1               # Input VCF (gzipped)
VCF_OUT_DIR=$2          # Output directory for filtered VCFs
PREFIX=$(basename "$VCF_IN" .vcf.gz)  # Prefix based on input VCF filename

# Ensure the output directory exists
mkdir -p "$VCF_OUT_DIR"

# Set filters
QUAL=30 #Set phred scrore minimum threhold
MIN_DEPTH=7.85 # mean - 3x  of mean variant depth
MAX_DEPTH=83.52 # mean + 3x  standard deviation of the mean variant depth
MISS=0.9 # Max missingness allowed for variants (10%).
          # This is set as the counterintuitive inverse of the % missingness you want to keep in vcftools

#Step 1: Remove individuals sequenced at very high or very low depths: 10x - 125x

SAMP_FILT_VCF="${VCF_OUT_DIR}/${PREFIX}_depthfilt_inds.vcf.gz"
bcftools view -S /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/vcg.gz.r3/vcfs_w_newmissfilt_newpops/Nofilt/qual_stats/individuals_to_keep.txt \
               -o "$SAMP_FILT_VCF" -Oz "$VCF_IN"

# Step 2: Initial filtering with bcftools to set low-quality genotypes to missing
# This uses allele balance to filter genotypes with a quality ratio < 0.9
BCFTOOLS_OUT1="${VCF_OUT_DIR}/${PREFIX}_allele_balance_filtered.vcf.gz"

bcftools +setGT "$SAMP_FILT_VCF" -- -t q -n . -i '(SMPL_MAX(FORMAT/AD)/(FORMAT/AD[:0]+FORMAT/AD[:1]) < 0.9)' | \
bcftools +setGT -- -t q -n c:'1/1' -i '(GT="0/1" && FORMAT/AD[:0]<FORMAT/AD[:1]) || (GT="1/0" && FORMAT/AD[:0]<FORMAT/AD[:1])' | \
bcftools +setGT -- -t q -n c:'0/0' -i '(GT="0/1" && FORMAT/AD[:0]>FORMAT/AD[:1]) || (GT="1/0" && FORMAT/AD[:0]>FORMAT/AD[:1])' | \
gzip -c > "$BCFTOOLS_OUT1"

# Check if allele balance filtering succeeded
if [ $? -ne 0 ]; then
    echo "Error: bcftools allele balance filtering failed."
    exit 1
fi

VCF_OUT="${VCF_OUT_DIR}/Pf3D7_dep10_90x_AB0.9_qcpass_White_Allchr_combined_final_filtered.vcf.gz"

vcftools --gzvcf "$BCFTOOLS_OUT1" \
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
