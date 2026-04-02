#!/bin/bash


# This script requires a
#   - <sample_list> : a text file listing sample IDs (one per line)
#   - <base_directory> : a path where the script will create a 'BAMs' subdirectory
#                        and store all downloaded and split BAM files there.
#
# The script will:
#   - download sample BAMs from the Pf7 release site
#   - index them
#   - split them by chromosome into individual BAMs
#   - index each split BAM
#   - place all files under $base_directory/BAMs/

# Check if the required arguments are provided

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <sample_list> <base_directory>"
    exit 1
fi


# Set variables based on user input
SAMPLE_LIST=$1
BASE_DIR=$2


# Create the base directory and a BAMs subdirectory
mkdir -p "$BASE_DIR/BAMs"


# Function to process each sample
process_sample() {
    ID=$1
    BASE_DIR=$2

    BAM_DIR="$BASE_DIR/BAMs"

    echo "Processing sample: $ID"
    
    # Download BAM file into the BAMs directory
    wget -q https://pf7_release.cog.sanger.ac.uk/bam/${ID}.bam -O "$BAM_DIR/${ID}.bam"
    samtools index "$BAM_DIR/${ID}.bam"
    
    # Split BAM into individual chromosomes and store in BAMs
    for CHR in {01..14}; do
        CHR_NAME="Pf3D7_${CHR}_v3"
        OUTPUT_BAM="$BAM_DIR/${ID}.${CHR_NAME}.bam"
        samtools view -b "$BAM_DIR/${ID}.bam" "$CHR_NAME" > "$OUTPUT_BAM"
        samtools index "$OUTPUT_BAM"
    done

    # Handle other chromosomes (mitochondria or apicoplast)
    for CHR_NAME in "Pf3D7_MIT_v3" "Pf3D7_API_v3"; do
        OUTPUT_BAM="$BAM_DIR/${ID}.${CHR_NAME}.bam"
        samtools view -b "$BAM_DIR/${ID}.bam" "$CHR_NAME" > "$OUTPUT_BAM"
        samtools index "$OUTPUT_BAM"
    done

    echo "BAM file for sample $ID split into chromosomes and saved in $BAM_DIR"
}


export -f process_sample


# Use GNU parallel to process each sample in parallel
parallel -j 4 process_sample {} "$BASE_DIR" :::: "$SAMPLE_LIST"


echo "All samples processed and BAM files split into chromosomes in $BASE_DIR/BAMs"