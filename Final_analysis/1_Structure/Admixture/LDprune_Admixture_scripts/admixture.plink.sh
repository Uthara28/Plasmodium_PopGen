#!/bin/bash
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH -J adm01.sh
#SBATCH --nodelist=node18

indir=/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/Structure/LD/admixture_white2011_abfilt/allchr
prefix=Allchr_ABfilt_hap

awk '{$1="00";print $0}' ${indir}/${prefix}.bim > ${indir}/${prefix}.bim.tmp
mv ${indir}/${prefix}.bim.tmp ${indir}/${prefix}.bim

for i in {1..4}; do
    for K in {2..10}; do
        admixture --cv -s time -j25 ${indir}/${prefix}.bed $K --haploid="*"| tee log_$((i))_$((K)).out
        mv ${prefix}.$K.Q ${prefix}.admix.$((i)).$((K)).Q
        mv ${prefix}.$K.P ${prefix}.admix.$((i)).$((K)).P
        echo -e "Admixture_k"$K"_iter"$i"\t"$K"\t"${prefix}".admix."$i"."$K".Q" >> filemap.txt
    done
done


