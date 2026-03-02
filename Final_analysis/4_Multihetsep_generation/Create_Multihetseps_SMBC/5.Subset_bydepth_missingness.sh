#!/bin/bash

# Input directories
VCF_DIR="$1"
BASE_DIR="$2"
OUTPUT_DIR="$3"

# Output files
FILE_DEPTH="${BASE_DIR}/depth_filtered_individuals.txt"
FILE_MISS="${BASE_DIR}/missingness_filtered_individuals.txt"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Create output files with headers (if they don't already exist)
if [ ! -f "$FILE_DEPTH" ]; then
    echo -e "Individual\tChromosome\tDepth" > "$FILE_DEPTH"
fi

if [ ! -f "$FILE_MISS" ]; then
    echo -e "Individual\tChromosome\tMissing_Sites\tMissing_Count\tMissing_Percentage" > "$FILE_MISS"
fi

# Python processing script to filter and select top individuals

python3 - <<EOF
import pandas as pd
import os

# Input files
depth_file = "$FILE_DEPTH"
miss_file = "$FILE_MISS"
outdir = "$OUTPUT_DIR"

# Read data
depth = pd.read_table(depth_file, delim_whitespace=True)
miss = pd.read_table(miss_file, delim_whitespace=True)

# Merge depth and missingness data
merged = pd.merge(depth, miss, on=["Individual", "Chromosome"], how="left")

# Group by Individual and calculate average Depth and Missing_Percentage across chromosomes
avg_metrics = (merged.groupby("Individual", as_index=False)
               .agg({"Depth": "mean", "Missing_Percentage": "mean"}))

# Filter for depth between 30 and 90
filtered = avg_metrics[(avg_metrics["Depth"] >= 30) & (avg_metrics["Depth"] <= 90)]

# Sort by Missing_Percentage and pick top 8 and 4 individuals
top_8 = filtered.sort_values(by="Missing_Percentage").head(8)
top_4 = filtered.sort_values(by="Missing_Percentage").head(4)

# Save outputs
if not os.path.exists(outdir):
    os.makedirs(outdir)

top_8.to_csv(os.path.join(outdir, "top_8_individuals.txt"), sep="\t", index=False)
top_4.to_csv(os.path.join(outdir, "top_4_individuals.txt"), sep="\t", index=False)
EOF

# Function to subset VCF files based on selected individuals
subset_vcf() {
    local TOP_FILE="$1"
    local NUM_INDIV="$2"  # Number of top individuals (4 or 8)
    
    # Ensure the file exists
    if [[ ! -f "$TOP_FILE" ]]; then
        echo "Error: $TOP_FILE not found. Skipping VCF subsetting."
        exit 1
    fi

    # Iterate over chromosomes
    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14; do
        CHROM=$(printf "%02d" $i)
        # Temporary file for individuals
        TEMP_FILE="${OUTPUT_DIR}/temp_chr${CHROM}_inds_${NUM_INDIV}.txt"
        tail -n +2 "$TOP_FILE" | cut -f1 | sort | uniq > "$TEMP_FILE"

        # Find the corresponding VCF file
        VCF_FILES=("$BASE_DIR"/Genotyped_gVCfs/*"_chr${CHROM}_cohort.allsites.geno.vcf.gz")

        if [ ${#VCF_FILES[@]} -eq 0 ]; then
            echo "Error: No VCF files found for Chromosome $CHROM in $VCF_DIR"
            rm "$TEMP_FILE"
            continue
        fi

        VCF_FILE="${VCF_FILES[0]}"
        OUTPUT_VCF="${OUTPUT_DIR}/chr${CHROM}_top${NUM_INDIV}_individuals_subset.allsites.geno.vcf.gz"

        # Subset VCF
        echo "Processing Chromosome $CHROM for the top $NUM_INDIV individuals..."
        bcftools view -S "$TEMP_FILE" "$VCF_FILE" -O z -o "$OUTPUT_VCF"
        bcftools index "$OUTPUT_VCF"

        # Cleanup
        rm "$TEMP_FILE"
    done

    echo "VCF subsetting completed for top $NUM_INDIV individuals per chromosome."
}

# Subset VCFs for top 4 individuals
subset_vcf "${OUTPUT_DIR}/top_4_individuals.txt" 4

# Subset VCFs for top 8 individuals
subset_vcf "${OUTPUT_DIR}/top_8_individuals.txt" 8
