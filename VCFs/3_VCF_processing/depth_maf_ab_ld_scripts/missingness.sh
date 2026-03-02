#!/bin/bash

# Input and output files
VCF_IN=$1    # Input VCF (gzipped, already filtered by allele balance and depth)
VCF_OUT=$2   # Output VCF (gzipped, after individual and variant missingness filtering)

# Set the filters
INDV_MISSINGNESS=0.1   # Max missingness allowed for individuals (10%)
SITE_MISSINGNESS=0.9   # Max missingness allowed for variants (10%)

# Temp files for storing intermediate results
TEMP_INDV_FILE=$(mktemp)

# Step 1: Identify and remove individuals with more than 10% missing data
echo "Identifying and removing individuals with more than 10% missing data..."

# Calculate the missingness per individual
vcftools --gzvcf $VCF_IN --missing-indv --out temp_indv_missingness

# Extract individuals with missingness > 10% and save them to a file
awk -v max_missing=$INDV_MISSINGNESS '$5 > max_missing {print $1}' temp_indv_missingness.imiss > $TEMP_INDV_FILE

# Remove individuals with > 10% missing data
if [ -s $TEMP_INDV_FILE ]; then
    echo "Removing individuals with more than 10% missing data..."
    vcftools --gzvcf $VCF_IN \
             --remove-indv $TEMP_INDV_FILE \
             --recode --stdout | bgzip > temp_filtered_no_high_missing_indv.vcf.gz
else
    echo "No individuals with more than 10% missingness found. Proceeding without removing individuals."
    cp $VCF_IN temp_filtered_no_high_missing_indv.vcf.gz
fi

# Step 2: Apply variant missingness filter
echo "Applying missingness filter for variants..."
vcftools --gzvcf temp_filtered_no_high_missing_indv.vcf.gz \
         --max-missing $SITE_MISSINGNESS \
         --recode --stdout | bgzip > $VCF_OUT

# Clean up temp files
rm $TEMP_INDV_FILE temp_filtered_no_high_missing_indv.vcf.gz temp_indv_missingness.imiss temp_indv_missingness.log

echo "Final filtered VCF saved to $VCF_OUT"
