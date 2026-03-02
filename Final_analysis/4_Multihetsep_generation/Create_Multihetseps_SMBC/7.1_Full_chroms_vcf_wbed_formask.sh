#!/bin/bash


# Define the input directory where VCF files are located
base_dir="$1"

# Validate the base directory input
if [[ -z "$base_dir" || ! -d "$base_dir" ]]; then
    echo "Error: Please provide a valid base directory as the first argument."
    exit 1
fi

# Create output directories (if they don’t exist)
mkdir -p "${base_dir}/filtered_vcfs"
mkdir -p "${base_dir}/BEDs"
mkdir -p "${base_dir}/Final_Masks"

# Process each VCF file in the ABfilt directory
for VCF_IN in "${base_dir}/ABfilt/"*.vcf.gz; do
    # Extract the file name without extension
    FILENAME=$(basename "$VCF_IN" .allsites.geno.vcf.gz)

    echo "Processing $FILENAME..."

    # Define input and output files
    input_vcf="${base_dir}/ABfilt/${FILENAME}.allsites.geno.vcf.gz"
    output_vcf="${base_dir}/filtered_vcfs/${FILENAME}_filtered.vcf.gz"
    FINAL_BED="${base_dir}/BEDs/${FILENAME}.bed"
    FINAL_MASK="${base_dir}/Final_Masks/${FILENAME}_merged.bed.gz"

    # Apply filters using bcftools
    bcftools view "$input_vcf" \
        --genotype ^miss \
        --apply-filters .,PASS \
        --include '((TYPE="snp" && INFO/DP > 30) || (TYPE="ref" && INFO/DP > 30))' \
        -Oz -o "$output_vcf" || { echo "bcftools failed for $FILENAME"; exit 1; }

    # Convert VCF to BED using vcf2bed
    echo "Converting filtered VCF to BED..."
    zcat "$output_vcf" | vcf2bed > "$FINAL_BED" || { echo "vcf2bed conversion failed for $FILENAME"; exit 1; }

    # Merge BED file using bedtools
    echo "Merging BED file..."
    bedtools merge -i "$FINAL_BED" | gzip > "$FINAL_MASK" || { echo "bedtools merge failed for $FILENAME"; exit 1; }

    echo "Final merged mask for $FILENAME saved to $FINAL_MASK"
done

echo "Processing complete for all VCF files."
