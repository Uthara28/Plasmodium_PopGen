#!/bin/bash

input_vcf="$1"
out_dir="$2"

# Check if the required arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input_vcf> <out_dir>"
  exit 1
fi

# Check if input VCF file exists
if [ ! -f "$input_vcf" ]; then
  echo "Error: Input VCF file '$input_vcf' does not exist."
  exit 1
fi

# Ensure output directory exists
mkdir -p "$out_dir"

# Extract the prefix from the input file name
prefix=$(basename "$input_vcf" .vcf.gz)

# Process the entire file without indexing
output_file="${out_dir}/${prefix}_haploid.vcf.gz"

# Convert to haploid using fixploidy and compress
bcftools +fixploidy "$input_vcf" -Oz -o "$output_file" -- -f 1

echo "Processed haploid VCF: $output_file"
