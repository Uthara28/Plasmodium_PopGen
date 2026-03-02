#!/bin/bash
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH --time=48:00:00
#SBATCH -J 08ctv_adm.sh
#SBATCH --nodelist=node12

### Uthara Srinivasa
### LD pruning script

indir=/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/vcg.gz.r3/vcfs_w_newmissfilt_newpops/Depth_allelebal_hap/
prefix=Pf3D7_dep10_90x_AB0.9_qcpass_White_Allchr_combined_final_filtered_haploid
OUTPUT=Allchr_ABfilt_hap


plink --vcf ${indir}/${prefix}.vcf.gz \
--double-id \
--allow-extra-chr \
--set-missing-var-ids @:# \
--out $OUTPUT \
--make-bed \
--geno 0.05 \
--no-sex \
--chr-set -14





