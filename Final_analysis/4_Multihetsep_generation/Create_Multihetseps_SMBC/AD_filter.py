import argparse
import os

# Set up argument parser
parser = argparse.ArgumentParser(description='Filter sites based on allelic balance from bcftools query output.')
parser.add_argument('--input', type=str, required=True, help='Path to the input txt file from bcftools query.')
parser.add_argument('--output_dir', type=str, required=True, help='Directory to save the temp_sites.txt file.')
parser.add_argument('--AB_ratio', type=float, default=0.9, help='Allelic balance ratio threshold.')
args = parser.parse_args()

def calculate_allelic_balance(ad_values):
    """Calculate allelic balance as the highest AD divided by the sum of ADs."""
    try:
        ad_ints = [int(x) for x in ad_values.split(",") if x.isdigit()]
        if sum(ad_ints) == 0:
            return 0  # Avoid division by zero
        return max(ad_ints) / sum(ad_ints)
    except ValueError:
        return 0  # Return 0 if there is a problem with conversion

# Create list to store site names and positions
temp_sites = []

# Process input file
with open(args.input, 'r') as infile:
    for line in infile:
        # Strip any leading/trailing whitespace
        line = line.strip()
        # Skip empty lines
        if not line:
            continue
        # Split the line into columns
        columns = line.split('\t')
        
        # Handle lines with fewer columns (e.g., header or misformatted lines)
        if len(columns) < 4:
            continue
        
        # Extract site name and position (columns 1 and 2)
        site_name = columns[0]
        position = columns[1]

        # Check if the 4th column contains an ALT allele (i.e., it is not ".")
        has_alt_allele = columns[3] != "."

        # Extract allelic depth values for each sample, starting from the 5th column
        ad_values = columns[4:]  # Starting from the 5th column
        
        # Check if all samples meet the allelic balance condition
        allelic_balance_satisfied = all(calculate_allelic_balance(ad) >= args.AB_ratio for ad in ad_values)

        # Determine if the line should be kept:
        if not has_alt_allele or allelic_balance_satisfied:
            # Add site name and position to the temp_sites list
            temp_sites.append(f"{site_name}\t{position}")

# Define the output file path
output_file_path = os.path.join(args.output_dir, "temp_sites.txt")

# Write site names and positions to temp_sites.txt
with open(output_file_path, 'w') as temp_sites_file:
    temp_sites_file.write('\n'.join(temp_sites) + '\n')

print(f"Site names and positions saved to {output_file_path}")
