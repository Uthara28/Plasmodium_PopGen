#!/bin/bash

# This script requires a
#   - <VCF_DIR>  : directory containing GT‑filled, allsites geno VCFs (*.allsites.geno.vcf.gz)
#   - <BASE_DIR> : writable directory where filtered VCFs will be written under ./ABfilt/
#   - bcftools with the +setGT plugin and bgzip in PATH

# What it does
#   - applies three allele‑balance (AB) filters using bcftools +setGT:
#       1. sets genotype to missing if max(AD)/sum(AD) < 0.9
#       2. sets 0/1 or . → 1/1 if AD[0] < AD[1]
#       3. sets 0/1 or . → 0/0 if AD[0] > AD[1]
#   - outputs filtered VCFs named *_ABfilt.allsites.geno.vcf.gz in $BASE_DIR/ABfilt/
#   - indexes each filtered VCF with bcftools index
# This step is optional and should be used only when an extra‑conservative allele‑balance filter is desired
# before downstream analyses 


# Define input and output directories
VCF_DIR="$1"          # Directory containing the VCF files
BASE_DIR="$2"       # Directory to store output VCF files

# Create output directory if it doesn't exist
mkdir -p "$BASE_DIR/ABfilt"


# Loop over each VCF file in the input directory
for VCF_IN in "$VCF_DIR"/*.vcf.gz; do
    # Get the base name of the VCF file (without path)
    FILENAME=$(basename "$VCF_IN" .allsites.geno.vcf.gz)
    
    # Apply the first +setGT filter (AD ratio < 0.9)
    bcftools +setGT "$VCF_IN" -- -t q -n . -i '(SMPL_MAX(FORMAT/AD)/(FORMAT/AD[:0]+FORMAT/AD[:1]) < 0.9)' | \
    
    # Apply the second +setGT filter (GT "0/1" or "." with AD[:0] < AD[:1])
    bcftools +setGT -- -t q -n c:'1/1' -i '(GT="0/1" && FORMAT/AD[:0]<FORMAT/AD[:1]) || (GT="1/0" && FORMAT/AD[:0]<FORMAT/AD[:1]) || (GT="." && FORMAT/AD[:0]<FORMAT/AD[:1])' | \
    
    # Apply the third +setGT filter (GT "0/1" or "." with AD[:0] > AD[:1])
    bcftools +setGT -- -t q -n c:'0/0' -i '(GT="0/1" && FORMAT/AD[:0]>FORMAT/AD[:1]) || (GT="1/0" && FORMAT/AD[:0]>FORMAT/AD[:1]) || (GT="." && FORMAT/AD[:0]>FORMAT/AD[:1])' | \
    
    # Compress the final VCF output with bgzip
    bgzip -c > "${BASE_DIR}/ABfilt/${FILENAME}_ABfilt.allsites.geno.vcf.gz"
    
    bcftools index "${BASE_DIR}/ABfilt/${FILENAME}_ABfilt.allsites.geno.vcf.gz"
    
    echo "Output saved to $BASE_DIR/${FILENAME}_ABfilt.allsites.geno.vcf.gz"
done

echo "Processing complete for all VCF files in $VCF_DIR."
