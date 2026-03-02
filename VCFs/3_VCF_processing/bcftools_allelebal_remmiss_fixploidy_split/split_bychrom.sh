#!/bin/bash

# Input VCF file path and output directory
input_vcf="$1"
out_dir="$2"

# Check if input and output directory arguments are provided
if [ -z "$input_vcf" ] || [ -z "$out_dir" ]; then
  echo "Usage: $0 <input_vcf> <out_dir>"
  exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$out_dir"

# Extract the prefix from the input file name (without the .vcf.gz extension)
prefix=$(basename "$input_vcf" .vcf.gz)

# Get the list of chromosomes
bcftools query -f '%CHROM\n' "$input_vcf" | sort | uniq > "${out_dir}/chromosomes.txt"

# Process each chromosome
while read -r chrom; do
  # Define the output file name for each chromosome in the output directory
  output_file="${out_dir}/${prefix}_${chrom}.vcf.gz"
  
  # Extract data for the specific chromosome and save to a gzipped VCF
  bcftools view -r "$chrom" "$input_vcf" | bgzip > "$output_file"

  echo "Processed: $output_file"
done < "${out_dir}/chromosomes.txt"

echo "All chromosomes have been processed."
