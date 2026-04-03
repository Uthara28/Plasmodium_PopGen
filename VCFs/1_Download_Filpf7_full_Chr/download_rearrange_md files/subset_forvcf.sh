#!/bin/bash
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH --time=48:00:00
#SBATCH -J vcf_download.sh



# Assuming your R script is executed correctly
Rscript --vanilla /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/Samplemd_files/subset_forvcf.R

# Set the heading/sr number column straight due to formatting error
# The 'tail -n +2' command is used to remove the first line (header)

tail -n +2 SamplesIds_for_vcf_cam.thai.viet.txt > SamplesIds_for_vcf_cam.thai.viet_fixed.txt
# Removes the header line from 'SamplesIds_for_vcf_cam.thai.viet.txt' and saves 

tail -n +2 SamplesIds_for_allse.pops.txt > SamplesIds_for_allse.pops_fixed.txt
# Removes the header line from 'SamplesIds_for_allse.pops.txt' and saves 

# Remove the original files to avoid redundancy
rm /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/Samplemd_files/SamplesIds_for_allse.pops.txt /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/Samplemd_files/SamplesIds_for_vcf_cam.thai.viet.txt

# remove rows without certain data available

