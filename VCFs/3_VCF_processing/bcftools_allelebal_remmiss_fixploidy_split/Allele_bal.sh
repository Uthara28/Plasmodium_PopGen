# Execute bcftools query and save output to a temporary file
    bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%AD]\n' $COHORT_VCF > $TEMP_QUERY_FILE

    # Filter sites based on allelic balance using a Python script
    python3 - <<EOF
import os

AB_RATIO_THRESHOLD = 0.9
TEMP_QUERY_FILE = "$TEMP_QUERY_FILE"
TEMP_SITES_FILE = "$TEMP_SITES_FILE"

def calculate_allelic_balance(ad_values):
    try:
        ad_ints = [int(x) for x in ad_values.split(",") if x.isdigit()]
        if sum(ad_ints) == 0:
            return 0
        return max(ad_ints) / sum(ad_ints)
    except ValueError:
        return 0

temp_sites = []

with open(TEMP_QUERY_FILE, 'r') as infile:
    for line in infile:
        line = line.strip()
        if not line:
            continue
        columns = line.split('\t')
        if len(columns) < 4:
            continue

        site_name = columns[0]
        position = columns[1]
        has_alt_allele = columns[3] != "."
        ad_values = columns[4:]

        allelic_balance_satisfied = all(calculate_allelic_balance(ad) >= AB_RATIO_THRESHOLD for ad in ad_values)

        if not has_alt_allele or allelic_balance_satisfied:
            temp_sites.append(f"{site_name}\t{position}")

with open(TEMP_SITES_FILE, 'w') as temp_sites_file:
    temp_sites_file.write('\n'.join(temp_sites) + '\n')

# Clean up temporary file
os.remove(TEMP_QUERY_FILE)

print(f"Site names and positions saved to {TEMP_SITES_FILE}")
EOF

    # Check if the temp_sites.txt file was created successfully
    if [ ! -f $TEMP_SITES_FILE ]; then
        echo "Failed to create temp_sites.txt for chromosome $CHR. Skipping filtering."
        return
    fi

    # Filter VCF based on the filtered sites from the Python script
    bcftools view -T $TEMP_SITES_FILE $COHORT_VCF | \
        bcftools view \
            --genotype ^miss \
            --apply-filters .,PASS \
            --include '((TYPE="snp" && INFO/DP > 30) || (TYPE="ref" && INFO/DP > 30))' \
            -Oz -o $FILTERED_VCF_ALL_SITES || { echo "bcftools view failed for final filtering for chromosome $CHR"; exit 1; }
    