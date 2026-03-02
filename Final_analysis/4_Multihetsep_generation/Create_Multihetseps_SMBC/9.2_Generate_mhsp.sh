#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <coh_prefix> <ind_prefix> <in_dir> <mask_dir> <out_dir>"
    exit 1
fi

#in_dir: contains individual vcfs

# Set variables from input arguments
COH_PREFIX=$1
IND_PREFIX=$2
IND_VCF_DIR=$3
MASK_DIR=$4
OUT_DIR=$5

# Create the output directory if it does not exist
mkdir -p $OUT_DIR

# Loop over chromosomes 01 to 14
for MASK in "${MASK_DIR}/"*_merged.bed.gz; do

    filename=$(basename "$MASK" _subset_merged.bed.gz)
    #chr_number=$(echo "$filename" | sed -E 's/^chr([0-9]{2})_.*/\1/')
    #top_individuals=$(echo "$filename" | sed -E 's/^.*(top_[0-9]+_individuals).*$/\1/')
    
    echo "processing file $filename"

    # Prepare the mask file path
    MASK="$MASK_DIR/${filename}_subset_merged.bed.gz"

    # Check if the mask file exists and is a .bed.gz file
    if [ ! -f "$MASK" ] || [[ ! "$MASK" =~ \.bed\.gz$ ]]; then
        echo "Mask file $MASK does not exist or is not a .bed.gz file. Skipping chromosome $CHR."
        continue
    fi

    # Initialize the Python script command with the mask file
    PYTHON_CMD="python3  /home/usriniva/Desktop/masters/plasmodium/Final_analysis/5_Multihetsep_generation/Create_Multihetseps_SMBC/generate_multihetsep_hap.py --mask=$MASK"

    # Find all unique individual VCF files for the current chromosome and append to Python command
    for VCF_FILE in $IND_VCF_DIR/${filename}_subset.allsites.geno.vcf.gz_${IND_PREFIX}*.vcf.gz; do
         # Check if the file exists and ends with .vcf.gz
        if [[ $VCF_FILE == *.vcf.gz ]]; then 
            PYTHON_CMD+=" $VCF_FILE"
        fi
    done

    # Set the output file path
    OUTPUT_FILE="$OUT_DIR/${COH_PREFIX}_${filename}.mhs"

    # Execute the Python script and redirect output to file
    echo "Processing chromosome $CHR..."
    eval "$PYTHON_CMD > $OUTPUT_FILE"

    echo "Output saved to $OUTPUT_FILE"

done

echo "Processing complete."