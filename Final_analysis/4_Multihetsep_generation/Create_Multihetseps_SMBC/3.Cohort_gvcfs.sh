#!/bin/bash




# This script requires a directory structure where:
#   - <input_dir> contains sample ID wise VCF files to be processed.
#   - <BASE_DIR> is an existing or writable directory for all generated outputs.
#   - <reference_file> is the reference genome used for variant calling (FASTA with index files).
#   - <ind_prefixes> is a comma-separated list of sample prefix starting letters, 
#for easy searchability. If all samples start with either 'PD or PH', set to "PD,PH", if all samples start with W; set to "W" and so on
#   - <cohort_prefix> defines the name prefix for combined cohort-level outputs. Here you can define as you like; so subpop labels like "Maesot" or "NCV" works 

# OUTPUTS
# This script jointly processes per‑sample, per‑chromosome GVCFs into:
#   - a cohort‑level combined GVCF for each chromosome (using CombineGVCFs)
#   - and a corresponding genotyped (all‑sites) VCF using GenotypeGVCFs.

# It expects that:
#   - GVCFs are stored under <input_dir> with naming pattern like
#     <prefix>...Chr<NN>.g.vcf.gz
#   - a reference genome is available with index files
#   - sample prefixes (e.g., "PD,PH") are provided for easy pattern matching

# Output is written to:
#   - $BASE_DIR/Cohort.g.VCFs/ for combined GVCFs
#   - $BASE_DIR/Genotyped_gVCfs/ for genotyped VCFs

## Run using: ./Cohort_gvcfs.sh /path/to/input_dir /path/to/BASE_DIR /path/to/reference.fasta "PD,PH" "NCV"

if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <input_dir> <BASE_DIR> <reference_file> <ind_prefix1,ind_prefix2> <cohort_prefix>"
    exit 1
fi

# Set base paths and inputs
INPUT_DIR=$1       # Directory with the VCFs
BASE_DIR=$2      # Output/overarching directory
REFERENCE=$3       # Reference file
IND_PREFIXES=$4    # Comma-separated list of prefixes,  "PD,PH" or just "P" should work (given tall samples start with 'P')
COHORT_PREFIX=$5   # Cohort file prefix

# Convert comma-separated prefixes into an array
IFS=',' read -r -a PREFIX_ARRAY <<< "$IND_PREFIXES"

# Create necessary output directories if they don't exist
mkdir -p "$BASE_DIR/Cohort.g.VCFs"
mkdir -p "$BASE_DIR/Genotyped_gVCfs"

# Function to process each chromosome
process_chromosome() {
    local CHR=$1
    local INPUT_DIR=$2      # Local input directory
    local BASE_DIR=$3     # Local output directory
    local REFERENCE=$4      # Local reference file
    local PREFIX_ARRAY=$5   # Local prefix array
    local COHORT_PREFIX=$6  # Local cohort prefix (set in the function)
    local GATK_CMD
    local COMBINED_GVCF
    local GENOTYPED_VCF

    # Initialize the GATK command for CombineGVCFs for the current chromosome
    GATK_CMD="gatk CombineGVCFs -R $REFERENCE"
    
    # Flag to check if any variant file is found
    VARIANT_FOUND=false

    # Loop over each prefix in PREFIX_ARRAY to collect variant files for the current chromosome
    for PREFIX in "${PREFIX_ARRAY[@]}"; do
        # Find GVCF files in the INPUT_DIR that match the current chromosome and prefix
        for variant in "${INPUT_DIR}"/${PREFIX}*.Chr${CHR}.g.vcf.gz; do
            # Check if the file exists
            if [[ -f $variant ]]; then
                # Add the variant file to the GATK command
                GATK_CMD+=" --variant $variant"
                VARIANT_FOUND=true
            else
                echo "Warning: File $variant does not exist, skipping."
            fi
        done
    done

    # If no variants were found, exit the function
    if ! $VARIANT_FOUND; then
        echo "No variant files found for chromosome $CHR. Skipping..."
        return
    fi

    # Set the output file name for CombineGVCFs
    COMBINED_GVCF="$BASE_DIR/Cohort.g.VCFs/${COHORT_PREFIX}_chr${CHR}_cohort.g.vcf.gz"
    GATK_CMD+=" -O $COMBINED_GVCF"
    
    # Execute the GATK CombineGVCFs command
    echo "Executing: $GATK_CMD"
    eval $GATK_CMD || { echo "GATK CombineGVCFs failed for chromosome $CHR"; exit 1; }

    # Index the combined GVCF file
    echo "Indexing combined GVCF file: $COMBINED_GVCF"
    gatk IndexFeatureFile -I "$COMBINED_GVCF" || { echo "GATK IndexFeatureFile failed for $COMBINED_GVCF"; exit 1; }

    # Set the output file name for GenotypeGVCFs
    GENOTYPED_VCF="$BASE_DIR/Genotyped_gVCfs/${COHORT_PREFIX}_chr${CHR}_cohort.allsites.geno.vcf.gz"

    # Check if the combined GVCF file exists before proceeding with GenotypeGVCFs
    if [ -f "$COMBINED_GVCF" ]; then
        # Execute GenotypeGVCFs for the combined GVCF file
        echo "Executing GenotypeGVCFs for chromosome $CHR"
        gatk --java-options "-Xmx4g" GenotypeGVCFs \
            -R $REFERENCE \
            -V "$COMBINED_GVCF" \
            --include-non-variant-sites \
            -O "$GENOTYPED_VCF" || { echo "GATK GenotypeGVCFs failed for chromosome $CHR"; exit 1; }

        # Index the genotyped VCF file
        echo "Indexing genotyped VCF file: $GENOTYPED_VCF"
        gatk IndexFeatureFile -I "$GENOTYPED_VCF" || { echo "GATK IndexFeatureFile failed for $GENOTYPED_VCF"; exit 1; }
    else
        echo "Combined GVCF file $COMBINED_GVCF does not exist. Skipping GenotypeGVCFs for chromosome $CHR."
    fi
}

# Export the function for parallel processing
export -f process_chromosome

# Run the process for chromosomes 01 to 14 in parallel using GNU Parallel
echo "Starting parallel processing for chromosomes..."
seq -w 01 14 | parallel --verbose process_chromosome {} "$INPUT_DIR" "$BASE_DIR" "$REFERENCE" "${PREFIX_ARRAY[@]}" "$COHORT_PREFIX"

echo "Cohort VCF creation and genotype calling completed for all chromosomes."
