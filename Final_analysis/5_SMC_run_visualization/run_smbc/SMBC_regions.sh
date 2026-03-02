#!/bin/bash

# Set input and output directories and mutation rate
input_dir="$1"
output_dir="$2"
mut_rate="$3"

# Ensure input, output directories, and mutation rate are specified
if [[ -z "$input_dir" || -z "$output_dir" || -z "$mut_rate" ]]; then
    echo "Usage: $0 <input_directory> <output_directory> <mutation_rate>"
    exit 1
fi

# Check if input directory exists
if [[ ! -d "$input_dir" ]]; then
    echo "Input directory does not exist: $input_dir"
    exit 1
fi

# Define a mutation-rate specific output directory
output_dir_with_rate="${output_dir}/mut_rate_${mut_rate}"
mkdir -p "$output_dir_with_rate"

# Find all .mhs files in the input directory
mhs_files=($(find "$input_dir" -type f -name "*.mhs"))
file_count=${#mhs_files[@]}

# Dynamically adjust for SLURM array size based on file count
if [[ "$file_count" -eq 0 ]]; then
    echo "No .mhs files found in input directory: $input_dir"
    exit 1
fi

# Process function for each .mhs file
process_mhs() {
    local mhs_file="$1"
    local input_loc="$2"
    local output_dir="$3"
    local mut_rate="$4"

    # Define output subdirectory based on .mhs file path structure
    prefix=$(basename "$mhs_file" .mhs)
    output_subdir="${output_dir}/$(dirname "${mhs_file#$input_loc/}")"
    recomb_rate="7.4e-07"  # Set recombination rate
    mkdir -p "$output_subdir"
    
    # Create a log file specific to the .mhs file
    log_file="${output_subdir}/${prefix}_log.txt"

    # Log the processing details and execute the R script
    {
        echo "Processing file: $mhs_file"
        echo "Output subdirectory: $output_subdir"
        echo "Mutation rate: $mut_rate"
        echo "Recombination rate: $recomb_rate"
        echo "Executing command:"
        echo "Rscript --vanilla /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/SMC/SMBC_regions/SMBC_regions.R \"$mhs_file\" \"$output_subdir\" \"$mut_rate\" \"$recomb_rate\""
        echo "------------------------"
    } >> "$log_file"

    # Execute the R script with the .mhs file and log output
    Rscript --vanilla /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/SMC/SMBC_regions/submit_smbc/SMBC_regions.R \
    "$mhs_file" "$output_subdir" "$mut_rate" "$recomb_rate" >> "$log_file" 2>&1
}

export -f process_mhs  # Export function for parallel execution

# Find all .mhs files and run them in parallel with the process_mhs function
find "$input_dir" -type f -name "*.mhs" | parallel --verbose -j 20 process_mhs {} "$input_dir" "$output_dir_with_rate" "$mut_rate"
