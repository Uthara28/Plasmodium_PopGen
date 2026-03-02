#!/bin/bash

base_dir=$1

# Ensure output directory exists
mkdir -p "$base_dir/individual_vcfs"

# Loop through each VCF file in the specified directory
for vcf_file in "${base_dir}/Subset_gVCFs/"*.vcf.gz; do
    filename=$(basename "$vcf_file" _subset.vcf.gz)
    
    # Check if the VCF file exists
    if [[ ! -f "$vcf_file" ]]; then
        echo "VCF file not found: $vcf_file. Skipping."
        continue
    fi

    # Apply filters and pipe the output directly into the sample extraction loop
    echo "Filtering and processing VCF file $vcf_file..."

    # Use bcftools to filter the VCF and extract individual samples in a pipeline
    filtered_vcf=$(mktemp)  # Create a temporary file to store filtered VCF

    # Filter VCF and store the result in a temporary file
    bcftools view "$vcf_file" \
        --genotype ^miss \
        --apply-filters .,PASS \
        --include 'TYPE="snp"' \
        --output-type z -o "$filtered_vcf" || {
            echo "Filtering failed for $vcf_file."
            rm -f "$filtered_vcf"
            continue  # Skip this file and continue with the next one
        }

    # Extract each individual sample from the filtered VCF file
    for indv in $(bcftools query -l "$filtered_vcf"); do
        echo "Extracting sample $indv from filtered VCF for $filename..."

        # Run bcftools view to extract individual sample VCFs
        bcftools view "$filtered_vcf" \
            --samples "$indv" \
            --output-type z \
            --output-file "$base_dir/individual_vcfs/${filename}_$indv.vcf.gz" || {
                echo "Extraction failed for sample $indv on $filename"
                continue  # Continue to the next sample instead of exiting the script
            }
    done

    # Clean up the temporary filtered VCF file
    rm -f "$filtered_vcf"
done

echo "Processing complete."

