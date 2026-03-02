# Step 2: Run vcftools quality check
VCF=$1  #input subsetted vcf
OUT="Pf3D7_dep10_90x_AB0.9_qcpass_White_Allchr"
OUTPUT_DIR=$2

mkdir $OUTPUT_DIR

# Move to the output directory
cd "$OUTPUT_DIR"

# Run vcftools commands
vcftools --gzvcf "$VCF" --freq2 --out "$OUT" --max-alleles 2
vcftools --gzvcf "$VCF" --depth --out "$OUT"
vcftools --gzvcf "$VCF" --site-mean-depth --out "$OUT"
vcftools --gzvcf "$VCF" --site-quality --out "$OUT"
vcftools --gzvcf "$VCF" --missing-indv --out "$OUT"
vcftools --gzvcf "$VCF" --missing-site --out "$OUT"
vcftools --gzvcf "$VCF" --het --out "$OUT"

