#!/bin/bash

## Run using: ./run_haplotypecaller.sh /path/to/reference.fasta /path/to/base_directory
# This script requires a base directory containing BAM files from across all individuals and chromosomes.

# Check if the necessary arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <reference_file> <base_directory> <bam_dir>"
    exit 1
fi

# Command-line arguments
reference="$1"
base_dir="$2"
bam_dir="$3"
# Create the output directory if it does not exist
mkdir -p "$base_dir/VCFs"

# Function to run GATK HaplotypeCaller
run_haplotypecaller() {
    bam_file="$1"
    
    # Extract the sample ID and chromosome name from the BAM file name
    file_name=$(basename "$bam_file")
    sample_id=$(echo "$file_name" | cut -d '.' -f 1)
    chr_name=$(echo "$file_name" | sed -E 's/.*(Pf3D7_[0-9]+_v3).*/\1/')

    # Check if chr_name extraction was successful
    if [[ ! "$chr_name" =~ Pf3D7_[0-9]+_v3 ]]; then
        echo "Failed to extract chromosome name from $file_name"
        return 1
    fi

    # Extract chromosome number
    chr_num=$(echo "$chr_name" | sed -E 's/Pf3D7_([0-9]+)_v3/\1/')
    
    # Check if chr_num extraction was successful
    if [[ ! "$chr_num" =~ ^[0-9]+$ ]]; then
        echo "Failed to extract chromosome number from $chr_name"
        return 1
    fi

    # Define the output GVCF file path
    output_gvcf="$base_dir/VCFs/${sample_id}.Chr${chr_num}.g.vcf.gz"

    # Run GATK HaplotypeCaller
    gatk --java-options "-Xmx4g" HaplotypeCaller \
        -R "$reference" \
        -I "$bam_file" \
        -O "$output_gvcf" \
        -ERC GVCF \
        --output-mode EMIT_ALL_CONFIDENT_SITES \
        -L "$chr_name"

    if [[ $? -ne 0 ]]; then
        echo "GATK HaplotypeCaller failed for sample $sample_id on chromosome $chr_num"
        return 1
    fi

    echo "Processed chromosome $chr_name for sample $sample_id"

    # Index the output GVCF file
    tabix -p vcf "$output_gvcf" || { echo "Indexing failed for $output_gvcf"; return 1; }
}

export -f run_haplotypecaller

# Export the reference and base_dir for use in parallel
export reference
export base_dir

# Iterate over all BAM files in the BAMs directory and run in parallel
find "$bam_dir/BAMs/" -name "*.bam" | parallel run_haplotypecaller

echo "Processing complete."
