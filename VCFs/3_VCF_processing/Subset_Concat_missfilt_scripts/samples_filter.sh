#!/bin/bash

cd /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/VCF_filtered/Subset_sampleids_forvcfs

# Set the input file path
input_file="/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/VCF_filtered/Subset_sampleids_forvcfs/Pf7_md_fws_res.txt" 

head -1 "$input_file" | sed 's/\./_/g'> Pf7_header.txt
# Use tail to skip the first line and save the rest of the data to a temporary file
tail -n +2 "$input_file" | cut -f2- -d$'\t'> tmpfile.txt

paste -d'\n' Pf7_header.txt tmpfile.txt > Pf7_md_fws_res_fixed.txt

