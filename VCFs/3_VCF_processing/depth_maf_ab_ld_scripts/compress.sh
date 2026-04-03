#!/bin/bash

# Check if input and output directory are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_vcf.gz> <output_directory>"
    exit 1
fi

# Input and output files
VCF_IN=$1               # Input VCF (gzipped)
VCF_OUT_DIR=$2          # Output directory for the final compressed VCFs
PREFIX=$(basename "$VCF_IN" .vcf.gz)  # Prefix based on input VCF filename

# Ensure the output directory exists
mkdir -p "$VCF_OUT_DIR"

# Step 1: Uncompress the gzipped VCF file to a temporary file
TEMP_VCF="${VCF_OUT_DIR}/${PREFIX}.vcf"
gunzip -c "$VCF_IN" > "$TEMP_VCF"

# Step 2: Compress the VCF file with BGZF
BGZF_VCF="${VCF_OUT_DIR}/${PREFIX}.vcf.gz"
bgzip "$TEMP_VCF"

# Check if BGZF compression succeeded
if [ $? -ne 0 ]; then
    echo "Error: BGZF compression failed."
    exit 1
fi

# Step 3: Index the BGZF compressed VCF file
bcftools index "$BGZF_VCF"

# Check if indexing succeeded
if [ $? -ne 0 ]; then
    echo "Error: Indexing of the VCF file failed."
    exit 1
fi

# Cleanup: Remove the uncompressed VCF file
rm "$TEMP_VCF"

# Confirmation message
echo "Successfully uncompressed, compressed with BGZF, and indexed the file."
echo "Final output: $BGZF_VCF"
