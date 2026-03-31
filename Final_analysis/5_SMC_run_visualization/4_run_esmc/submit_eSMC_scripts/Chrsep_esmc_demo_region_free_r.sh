#!/bin/bash

# Input arguments
input_dir="$1"
output_dir="$2"
mut_rate="$3"

# Validate input
if [[ -z "$input_dir" || -z "$output_dir" || -z "$mut_rate" ]]; then
    echo "Usage: $0 <input_directory> <output_directory> <mutation_rate>"
    exit 1
fi

# Define output directory
output_dir_with_rate="${output_dir}/mut_rate_${mut_rate}"
mkdir -p "$output_dir_with_rate"

# Function to process mhs file
process_mhs() {
    local mhs_file="$1"
    local output_dir="$2"
    local mut_rate="$3"
    recomb_rate="7.4e-07"

    prefix=$(basename "$mhs_file" .mhs)
    output_subdir="${output_dir}/$(dirname "${mhs_file#$input_dir/}")"
    mkdir -p "$output_subdir"

    log_file="${output_subdir}/${prefix}_log.txt"
    echo "Processing: $mhs_file" >> "$log_file"

    Rscript --vanilla /home/usriniva/Desktop/masters/plasmodium/Final_analysis/5_SMC_run_visualization/run_esmc/submit_eSMC_scripts/Chrsep_esmc_demo_regions_free_r.R \
    "$mhs_file" "$output_subdir" "$mut_rate" "$recomb_rate" >> "$log_file" 2>&1
}

# Export function and variables for GNU Parallel
export -f process_mhs
export input_dir output_dir_with_rate mut_rate

# Find .mhs files and process them in parallel
find "$input_dir" -type f -name "*.mhs" | parallel --verbose process_mhs {} "$output_dir_with_rate" "$mut_rate"
