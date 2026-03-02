#!/bin/bash

# Define the input directory where VCF files are located
base_dir="$1"

# Define the regions of interest for each chromosome (start-end position)
declare -A regions     # for Maesot

regions=(
    ["Pf3D7_01_v3"]="92901-457931,460312-575900"
    ["Pf3D7_02_v3"]="105801-447300,450451-862500"
    ["Pf3D7_03_v3"]="70631-597816,600276-1003060"
    ["Pf3D7_04_v3"]="91421-545800,614901-642003,644530-935030,983081-1143990"
    ["Pf3D7_05_v3"]="37901-455740,457253-1321390"
    ["Pf3D7_06_v3"]="72351-478652,480972-723117,742801-1294830"
    ["Pf3D7_07_v3"]="77101-508360,605651-809245,811717-1381600"
    ["Pf3D7_08_v3"]="73561-299079,301404-427430,467341-1365730"
    ["Pf3D7_09_v3"]="79101-1242137,1244484-1473560"
    ["Pf3D7_10_v3"]="68971-1571815"
    ["Pf3D7_11_v3"]="110001-831968,834246-2003320"
    ["Pf3D7_12_v3"]="60301-766654,780451-1282773,1285068-1688600,1745531-2163700"
    ["Pf3D7_13_v3"]="74414-1168127,1170426-2791900"
    ["Pf3D7_14_v3"]="35775-1071523,1075090-3255710"
)

# Ensure the output directories exist
mkdir -p "$base_dir/regions_vcf_filtered"
mkdir -p "$base_dir/regions_BED"
mkdir -p "$base_dir/Final_Masks"
mkdir -p "$base_dir/Regions_Final_Masks"

# Loop through each VCF file in the specified directory
for VCF_IN in "${base_dir}/ABfilt/"*.vcf.gz; do
    # Extract the file name without extension
    filename=$(basename "$VCF_IN" .allsites.geno.vcf.gz)

    echo "Processing $filename..."

    chr_number=$(echo "$filename" | sed -E 's/^chr([0-9]{2})_.*/\1/')

    # Map the short chromosome name (e.g., chr09) to the full VCF filename (Pf3D7_09_v3)
    chrom_key="Pf3D7_${chr_number}_v3"  # This gets the full name from the shortened chromosome 
    
    echo "File name: $filename and chrom key: $chrom_key"

    # Check if the full chromosome name exists in the regions array
    if [[ -z "${regions[$chrom_key]}" ]]; then
        echo "Region for $chrom_key not found in the regions array. Skipping..."
        continue
    fi

    # Construct the input VCF file path
    input_vcf="${base_dir}/ABfilt/${filename}.allsites.geno.vcf.gz"

    # Check if the file exists
    if [[ ! -f "$input_vcf" ]]; then
        echo "File for $filename not found in $base_dir. Skipping..."
        continue
    fi

    # Define the region for this chromosome
    region="${regions[$chrom_key]}"
    
    # Define the output VCF file
    output_vcf="$base_dir/regions_vcf_filtered/${filename}_region_${region}.vcf.gz"
    
    echo "Extracting region $region from $chrom_key..."

    # Ensure the VCF file is indexed
    bcftools index "$input_vcf"

    # Loop through each region part (split by commas) and extract them
    temp_output_vcf=$(mktemp)
    for region_part in $(echo "$region" | tr ',' '\n'); do
        echo "Extracting region $region_part..."
        tabix -h "$input_vcf" "$chrom_key:$region_part" | \
        bcftools view \
            --genotype ^miss \
            --apply-filters .,PASS \
            --include '((TYPE="snp" && INFO/DP > 30) || (TYPE="ref" && INFO/DP > 30))' \
            -Oz >> "$temp_output_vcf"
    done

    # Compress the output
    mv "$temp_output_vcf" "$output_vcf"
    echo "Region $chrom_key:$region extracted to $output_vcf"
    
    # Convert VCF to BED using vcf2bed
    FINAL_BED="$base_dir/regions_BED/${filename}_region_${region}.bed"
    zcat "$output_vcf" | vcf2bed > "$FINAL_BED" || { echo "vcf2bed conversion failed for chromosome $filename"; continue; }

    # Merge the BED file using bedtools
    FINAL_MASK="${base_dir}/Regions_Final_Masks/${filename}_region_${region}_merged.bed"
    bedtools merge -i "$FINAL_BED" > "$FINAL_MASK" || { echo "bedtools merge failed for chromosome $filename"; continue; }

    # Compress the final merged mask file
    gzip "$FINAL_MASK" || { echo "gzip failed for final mask file for chromosome $filename"; continue; }

    echo "Final merged mask for $chrom_key saved to $FINAL_MASK.gz"

done

echo "Processing complete for all chromosomes."
