#!/bin/bash
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH -J remmiss.sh
#SBATCH --nodelist=node12

# Set the directory containing the VCF files
directory="/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/vcg.gz.r3"

# Loop over files starting with "Pf3D7" in the directory
for file in "$directory"/Pf3D7_12_*; do
    # Get the filename without the directory path and extension
    filename=$(basename "$file" .vcf.gz)
    
    # Define the output filename
    output="${filename}_0.miss.vcf.gz"
    
    # Filter variants with missingness
    bcftools filter -e 'F_MISSING > 0' "$file" -Oz -o "$output"

done


