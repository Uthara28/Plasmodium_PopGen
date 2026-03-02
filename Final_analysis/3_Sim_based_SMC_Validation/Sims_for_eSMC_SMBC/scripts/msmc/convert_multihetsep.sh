#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_directory> <output_directory>"
    exit 1
fi

# Directory to search for VCF files
INPUT_DIR=$1  # Pass the input directory as the first argument
OUTPUT_DIR=$2  # Pass the output directory as the second argument

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Function to process each VCF file
process_vcf() {
    vcf_file="$1"
    input_dir="$2"
    output_dir="$3"

    # Create the corresponding output subdirectory
    prefix=$(basename "$vcf_file" .vcf)
    output_subdir="${output_dir}/$(dirname "${vcf_file#$input_dir/}")"
    mkdir -p "$output_subdir"
    outfile="${prefix}"  # Ensure output file has .txt extension

    echo "Processing VCF file: $vcf_file"

    # Execute the R script with the current VCF file
    Rscript --vanilla /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/msprime_sims/Sims_for_eSMC_SMBC/scripts/convert_mhs.R "$vcf_file" "$output_subdir/$outfile" > "$output_subdir/${prefix}_Rscript_output.log" 2>&1 || {
        echo "R script failed for file: $vcf_file. Check log for details: ${prefix}_Rscript_output.log"
    }

    echo "Processed: $outfile"
}

# Export the function for use with parallel
export -f process_vcf

# Find all VCF files and process them in parallel
find "$INPUT_DIR" -type f -name "*.vcf" | parallel --jobs 20 process_vcf {} "$INPUT_DIR" "$OUTPUT_DIR"
