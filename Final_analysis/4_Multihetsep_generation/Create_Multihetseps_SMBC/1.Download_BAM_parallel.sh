#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <sample_list> <base_directory>"
    exit 1
fi

# Set variables based on user input
SAMPLE_LIST=$1
BASE_DIR=$2

# Create the base directory if it doesn't exist
mkdir -p "$BASE_DIR"

# Function to process each sample
process_sample() {
    ID=$1
    BASE_DIR=$2

    echo "Processing sample: $ID"
    
    # Download BAM and BAI files directly into the base directory
    wget -q https://pf7_release.cog.sanger.ac.uk/bam/${ID}.bam -O "$BASE_DIR/${ID}.bam"
    samtools index "$BASE_DIR/${ID}.bam"
    
    # Split BAM file into individual chromosomes and store in the base directory
    for CHR in {01..14}; do
        CHR_NAME="Pf3D7_${CHR}_v3"
        OUTPUT_BAM="$BASE_DIR/${ID}.${CHR_NAME}.bam"
        samtools view -b "$BASE_DIR/${ID}.bam" "$CHR_NAME" > "$OUTPUT_BAM"
        samtools index "$OUTPUT_BAM"
    done

    # Handle other chromosomes if present (e.g., mitochondria or apicoplast)
    for CHR_NAME in "Pf3D7_MIT_v3" "Pf3D7_API_v3"; do
        OUTPUT_BAM="$BASE_DIR/${ID}.${CHR_NAME}.bam"
        samtools view -b "$BASE_DIR/${ID}.bam" "$CHR_NAME" > "$OUTPUT_BAM"
        samtools index "$OUTPUT_BAM"
    done

    echo "BAM file for sample $ID split into chromosomes and saved in $BASE_DIR"
}

export -f process_sample

# Use GNU parallel to process each sample in parallel
parallel -j 4 process_sample {} "$BASE_DIR" :::: "$SAMPLE_LIST"

echo "All samples processed and BAM files split into chromosomes."
