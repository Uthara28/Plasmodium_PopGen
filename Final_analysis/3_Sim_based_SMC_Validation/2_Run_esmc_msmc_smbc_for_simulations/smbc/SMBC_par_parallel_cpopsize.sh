#!/bin/bash

# Set input directory and output directory
input_dir="$1"
output_dir="$2"

# Ensure input and output directories are specified and exist
if [[ -z "$input_dir" || -z "$output_dir" ]]; then
    echo "Usage: $0 <input_directory> <output_directory>"
    exit 1
fi

if [[ ! -d "$input_dir" ]]; then
    echo "Input directory does not exist: $input_dir"
    exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Function to process each VCF file
process_vcf() {
    vcf_file="$1"
    input_loc="$2"  # Ensure this is set to the input directory
    output_dir="$3"

    # Create the corresponding output subdirectory
    prefix=$(basename "$vcf_file" .vcf)
    output_subdir="${output_dir}/$(dirname "${vcf_file#$input_loc/}")"
    mut_rate=$(echo "$prefix" | grep -oP '_m\K[0-9eE.-]+')
    mkdir -p "$output_subdir"
    
    # Create a log file specific to the VCF file being processed
    log_file="${output_subdir}/${prefix}_log.txt"

    # Print debugging information to log file
    {
        echo "Processing file: $vcf_file"
        echo "Output subdirectory: $output_subdir"
        echo "Mutation rate: $mut_rate"
        echo "Command executed:"
        echo "Rscript --vanilla /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/msprime_sims/Sims_for_eSMC_SMBC/scripts/esmc_sim.R \"$vcf_file\" \"$output_subdir\" \"$mut_rate\""
        echo "------------------------"
    } >> "$log_file"

    # Run the embedded R script with the VCF file and redirect both stdout and stderr to the log file
    Rscript --vanilla /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/msprime_sims/Sims_for_eSMC_SMBC/scripts/SMBC_par_parallel_cpopsize.R \
    "$vcf_file" "$output_subdir" "$mut_rate" >> "$log_file" 2>&1
}

export -f process_vcf  # Export function for use in parallel

# Find all .vcf files and run them in parallel with the embedded R script
find "$input_dir" -type f -name "*.vcf" | parallel -j 25 --verbose process_vcf {} "$input_dir" "$output_dir"

