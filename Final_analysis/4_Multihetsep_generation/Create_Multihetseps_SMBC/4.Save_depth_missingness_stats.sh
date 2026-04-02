#!/bin/bash

# This script requires a
#   - <VCF_DIR>  : directory containing cohort geno VCFs named like *chr[0-9]_cohort.allsites.geno.vcf.gz
#   - <BASE_DIR> : writable output directory for depth/missingness tables
#   - vcftools in PATH


# What it does
# For each chromosome VCF:
#   - runs vcftools --depth and --missing-indv
#   - appends per‑individual depth and missingness stats (by chromosome) to two tab‑separated files:
#     ${BASE_DIR}/depth_filtered_individuals.txt
#     ${BASE_DIR}/missingness_filtered_individuals.txt
# Output tables are then used later to subset individuals by depth and missingness thresholds.



VCF_DIR="$1"# Directory containing the VCF files
BASE_DIR="$2"  # Set your output directory, can use the 
OUTPUT_FILE_depth="${BASE_DIR}/depth_filtered_individuals.txt"
OUTPUT_FILE_miss="${BASE_DIR}/missingness_filtered_individuals.txt"

# Create output files and print headers only once
if [ ! -f "$OUTPUT_FILE_depth" ]; then
    echo -e "Individual\tChromosome\tDepth" > "$OUTPUT_FILE_depth"
fi

if [ ! -f "$OUTPUT_FILE_miss" ]; then
    echo -e "Individual\tChromosome\tMissing_Sites\tMissing_Count\tMissing_Percentage" > "$OUTPUT_FILE_miss"
fi

# Loop over each VCF file in the directory
for VCF_FILE in "$VCF_DIR"/*.geno.vcf.gz; do
    # Extract chromosome and population information from filename
    FILENAME=$(basename "$VCF_FILE")
    CHROM=$(echo "$FILENAME" | sed -E 's/.*_(chr[0-9]+)_cohort\.allsites\.geno\.vcf\.gz/\1/')

    # Run vcftools to get depth information
    vcftools --gzvcf "$VCF_FILE" --depth --out "${BASE_DIR}/temp_depth"
    
    # Check if vcftools succeeded and output exists
    if [[ -f "${BASE_DIR}/temp_depth.idepth" ]]; then
        # Skip the first line (header) and filter for individuals with average depth between 30 and 90
        tail -n +2 "${BASE_DIR}/temp_depth.idepth" | awk -v chrom="$CHROM" '{print $1, chrom, $3}' >> "$OUTPUT_FILE_depth"
    else
        echo "Depth file not generated for $VCF_FILE. Check for errors."
    fi
    
    # Run vcftools to get missingness information
    vcftools --gzvcf "$VCF_FILE" --missing-indv --out "${BASE_DIR}/temp_missingness"

    # Check if vcftools succeeded and output exists
    if [[ -f "${BASE_DIR}/temp_missingness.imiss" ]]; then
        # Skip the first line (header) and filter for individuals with missingness data
        tail -n +2 "${BASE_DIR}/temp_missingness.imiss" | awk -v chrom="$CHROM" '{print $1, chrom, $2, $4, $5}' >> "$OUTPUT_FILE_miss"
    else
        echo "Missingness file not generated for $VCF_FILE. Check for errors."
    fi
    
    # Cleanup temporary files
    rm -f "${BASE_DIR}/temp_depth.log" "${BASE_DIR}/temp_depth.idepth"
    rm -f "${BASE_DIR}/temp_missingness.log" "${BASE_DIR}/temp_missingness.imiss"
done

# Display final output files
echo "Individuals with depth between 30 and 90 saved in $OUTPUT_FILE_depth"
echo "Individuals with missingness data saved in $OUTPUT_FILE_miss"

# Optionally, display the contents of the output files
# cat "$OUTPUT_FILE_depth"
# cat "$OUTPUT_FILE_miss"
