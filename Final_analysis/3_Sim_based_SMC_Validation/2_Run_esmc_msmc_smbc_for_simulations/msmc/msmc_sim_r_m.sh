#!/bin/bash

# Check if the correct number of arguments is provided (minimum 3 are required)
usage() {
    echo "Usage: $0 <input_directory> <output_directory> <prefix> [time_segments] [indices]"
    exit 1
}

if [ "$#" -lt 3 ]; then
    usage
fi

# Set the input and output directories and prefix
INPUTDIR=$1
OUTPUTDIR=$2

# Set default log file
LOGFILE="${OUTPUTDIR}/msmc2_processing.log"

# Redirect stdout and stderr to log file, while still printing to console
exec > >(tee -a "$LOGFILE") 2>&1

# Handle optional time segments and indices argument
Time_segments="${3:-1*2+25*1+1*2+1*3}"  # Default time segments
Indices="${4:-0,1,2,3,4,5,6,7}"              # Default indices for 3 individuals

# Path to MSMC2 executable
MSMC2_EXEC="/data/proj2/home/students/u.srinivasan/.conda/envs/mamba/envs/msmc_env/bin/msmc2_Linux"
if [ ! -f "$MSMC2_EXEC" ]; then
    echo "MSMC2 executable not found at $MSMC2_EXEC"
    exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUTDIR"

# Function to process each txt file
process_file() {
    local txt_file="$1"
    
    # Get the relative path of the txt file with respect to INPUTDIR
    local relative_path="${txt_file#$INPUTDIR/}"
    
    # Determine the output file path and directory structure
    local base_name=$(basename "$txt_file" .txt)
    local output_subdir="${OUTPUTDIR}/$(dirname "$relative_path")"
    mut_rate=$(echo "$base_name" | grep -oP '_m\K[0-9eE.-]+')
    rho=1e-7

    # Calculate rho_over_mu using Python
    rho_over_mu=$(python3 -c "print(${rho} / ${mut_rate})")

    mkdir -p "$output_subdir"  # Ensure output directory structure exists
    
    local output_file="${output_subdir}/Popsize_${base_name}.msmc2"

    # Debugging: Print the command to be executed
    echo "Running MSMC2 on $txt_file with output $output_file and rho/mut_rate $rho_over_mu"

    # Run MSMC2 on each txt file
    "$MSMC2_EXEC" \
        -i 100 \
        -t 6 \
        -p "$Time_segments" \
        -r "$rho_over_mu" \
        -o "$output_file" \
        -I "$Indices" \
        "$txt_file"
}

export -f process_file  # Export the function to be used by parallel
export INPUTDIR OUTPUTDIR Time_segments Indices MSMC2_EXEC  # Export variables

# Find and run each .txt file in parallel
find "$INPUTDIR" -type f -name "*.txt" | parallel -j 15 process_file {}

echo "MSMC2 processing complete."
