#!/bin/bash

#!/bin/bash


# This script requires a
#   - cohort and individual prefix labels
#   - per‑chromosome, per‑top‑group (e.g., top4, top8) individual VCFs in $IND_VCF_DIR
#   - corresponding merged BED masks in $MASK_DIR
#   - generate_multihetsep.py located at the hardcoded path

# What it does
#   - for each merged‑mask BED file:
#     detects chromosome, top‑individual group, and region label from the filename
#   - runs `generate_multihetsep.py` over the matching set of individual VCFs
#   - writes one multihetsep file per chromosome‑group‑region into $MHSP_DIR
#   for downstream MSMC/PSMC2 runs.

# Check if the required arguments are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <coh_prefix> <ind_prefix> <individual_vcf_dir> <mask_dir> <MHSP_DIR>"
    exit 1
fi

# Set variables from input arguments
COH_PREFIX=$1
IND_PREFIX=$2
IND_VCF_DIR=$3
MASK_DIR=$4
MHSP_DIR=$5

# Create the output directory if it does not exist
mkdir -p "$MHSP_DIR"

# Loop over chromosomes 01 to 14
for MASK in "${MASK_DIR}/"*_merged.bed.gz; do


    filename=$(basename "$MASK" _merged.bed.gz)
    chr_number=$(echo "$filename" | sed -E 's/^chr([0-9]{2})_.*/\1/')
    echo "chr_number $chr_number"

    top_individuals=$(echo "$filename" | sed -E 's/.*(top[0-9]+_individuals).*/\1/')
    echo "top_individuals $top_individuals"

    # Extract region name from the mask filename
    region_part=$(echo "$filename" | sed -E 's/.*(region_[0-9,-]+).*/\1/')
    echo "region $region_part"


    # Prepare the mask file path
    MASK="$MASK_DIR/${filename}_merged.bed.gz"
    echo "processing file $filename and $MASK"

    # Ensure the mask file exists
    if [[ -z "$MASK" ]]; then
        echo "No mask file found for chromosome $filename. Skipping."
        continue
    else
        echo "Found mask file for chromosome $filename"
    fi

    
    # Construct the Python command
    PYTHON_CMD="python3 /home/usriniva/Desktop/masters/plasmodium/Final_analysis/4_Multihetsep_generation/Create_Multihetseps_SMBC/generate_multihetsep.py --mask=$MASK"

    # Find all unique individual VCF files for the current chromosome and append to Python command
    for VCF_FILE in $IND_VCF_DIR/chr${chr_number}_${top_individuals}_*${IND_PREFIX}*.vcf.gz; do
        # Check if the file exists and ends with .vcf.gz
        if [[ $VCF_FILE == *.vcf.gz ]]; then 
            PYTHON_CMD+=" $VCF_FILE"
        fi
    done

    # Set the output file path
    OUTPUT_FILE="$MHSP_DIR/${COH_PREFIX}_chr${chr_number}_${top_individuals}_${region_part}.mhs"

    # Execute the Python command and redirect output to the file
    echo "Processing chromosome $filename with region $region_part"
    eval "$PYTHON_CMD > \"$OUTPUT_FILE\""
    echo "Output saved to $OUTPUT_FILE"
done

echo "Processing complete."
