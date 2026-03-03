import sys
import os
import msprime
import numpy as np  # Importing NumPy for numerical operations
import os  # Importing os for operating system functionalities
import argparse  # Importing argparse for command-line argument parsing
import pandas as pd  # Importing pandas for DataFrame manipulation
import zipfile  # Importing zipfile for creating zip archives
import gzip  # Import gzip for Gzip compression

# Function to create an argument parser
def create_parser():
    parser = argparse.ArgumentParser(description="Simulate coalescent processes using msprime.")
    parser.add_argument('--output_dir', type=str, default="./output", 
                        help='Output directory for tree sequence or VCF files.')
    parser.add_argument('--output_format', type=str, choices=['vcf', 'ts'], default='vcf', 
                        help='Output format: "vcf" for Variant Call Format or "ts" for tree sequence.')
    parser.add_argument('--seed', type=int, required=True, help='Random seed for reproducibility.')
    parser.add_argument('--sim_id', type=int, required=True, help='Simulation ID')
    parser.add_argument('--sample_size', type=int, required=True, help='Number of samples for the simulation.')
    parser.add_argument('--length', type=int, default=1_000_000, help='Sequence length (in base pairs).')
    return parser

# User-defined parameters
num_time_points = 39  # Number of time points for demographic changes


# Demographic data
demography_data = {
    'years_ago': [
        20.90991, 27.04340, 34.97601, 45.23550, 58.50439,
        75.66543, 97.86030, 126.56557, 163.69094, 211.70625,
        273.80586, 354.12109, 457.99511, 592.33841, 766.08851,
        990.80457, 1281.43640, 1657.31899, 2143.45890, 2772.19779,
        3585.36410, 4637.05576, 5997.23919, 7756.40403, 10031.58311,
        12974.13845, 16779.83093, 21701.84380, 28067.62632, 36300.67815,
        46948.72375, 60720.15108, 78531.13893, 101566.60798, 131359.05066,
        169890.48403, 219724.30843, 284175.84417, 367532.89150
    ],
    'Ne_log10': [
        3.886466, 4.433363, 4.433363, 4.704220, 4.704220,
        4.701291, 4.701291, 4.696954, 4.696954, 4.691536,
        4.691536, 4.687589, 4.687589, 4.430142, 4.430142,
        4.060712, 4.060712, 3.114804, 3.114804, 3.860018,
        3.860018, 4.953656, 4.953656, 5.028866, 5.028866,
        6.221847, 6.221847, 6.621246, 6.621246, 6.746056,
        6.746056, 6.872533, 6.872533, 6.957109, 6.957109,
        6.885372, 6.885372, 6.300497, 6.300497
    ]
}

# Convert to DataFrame for easier manipulation
demography_df = pd.DataFrame(demography_data)

# Function to randomly sample parameters
def sample_random_params():
    beta_alpha = np.random.uniform(1, 1.9)  # Random alpha for Beta coalescent
    nearly_kingman_alpha = np.random.uniform(1.9, 1.991)  # Random alpha for nearly Kingman-like
    mutation_rate = np.exp(np.random.uniform(np.log(1e-10), np.log(1e-9)))
    recombination_rate = np.exp(np.random.uniform(np.log(1e-8), np.log(1e-6)))
    return beta_alpha, nearly_kingman_alpha, mutation_rate, recombination_rate

# Function to generate population times
def get_population_time(num_time_points):
    """Generate population times."""
    divided_years = demography_df['years_ago'] / 0.16  # Divide years_ago by generation time
    divided_years=divided_years.sort_values()
    return  divided_years # Select evenly spaced time points

def sample_population_size(num_time_points, demography_fromdata):
    """Sample population sizes based on demographic data."""
    pop_sizes = np.zeros(num_time_points)
    
    # Ensure demography_df has enough rows
    total_rows = len(demography_fromdata)
    if total_rows == 0:
        raise ValueError("The demography DataFrame is empty.")
    
    # Adjust the loop to prevent out-of-bounds indexing
    for i in range(num_time_points):
        if i >= total_rows:
            raise IndexError(f"Index {i} is out of bounds for demography DataFrame with {total_rows} rows.")
        
        log10_Ne = demography_fromdata['Ne_log10'].iloc[i]
        Ne = 10 ** log10_Ne
        pop_sizes[i] = np.random.uniform(max(0, Ne - 1000), Ne + 1000)  # Sample within ±1000 around the population size
    
    return pop_sizes


# Function to simulate a Beta coalescent
def simulate_beta_coalescent(alpha, population_time, population_size, L, r, sample_size):
    """Simulate tree sequences using the Beta coalescent model with a given alpha."""
    demography_model = msprime.Demography()
    demography_model.add_population(initial_size=population_size[0])
    for time, size in zip(population_time[1:], population_size[1:]):
        demography_model.add_population_parameters_change(time=time, initial_size=size)
    
    return msprime.sim_ancestry(samples=sample_size, recombination_rate=r,
                                 sequence_length=L, demography=demography_model,
                                 ploidy=1, model=msprime.BetaCoalescent(alpha=alpha))


    
# Function to simulate Kingman coalescent
def simulate_kingman_coalescent(population_time, population_size, L, r, sample_size):
    """Simulate tree sequences using Kingman coalescent (default settings)."""
    demography_model = msprime.Demography()
    demography_model.add_population(initial_size=population_size[0])
    for time, size in zip(population_time[1:], population_size[1:]):
        demography_model.add_population_parameters_change(time=time, initial_size=size)
    
    return msprime.sim_ancestry(samples=sample_size, recombination_rate=r,
                                 sequence_length=L, demography=demography_model, ploidy=1)

# Function to apply mutations to a tree sequence
def mutate_tree_sequence(tree_sequence, mutation_rate):
    """Apply mutations to the given tree sequence based on the mutation rate."""
    return msprime.sim_mutations(tree_sequence, rate=mutation_rate)

# Function to save simulation parameters to a text file
def save_parameters(seed, sim_id, beta_alpha, nearly_kingman_alpha, mutation_rate, recombination_rate, output_dir, file_name):
    """Save simulation parameters to a text file."""
    parameters = (f"Seed: {seed}\n"
                  f"Simulation no.: {sim_id}\n"
                  f"Beta Alpha: {beta_alpha}\n"
                  f"Nearly Kingman Alpha: {nearly_kingman_alpha}\n"
                  f"Mutation Rate: {mutation_rate}\n"
                  f"Recombination Rate: {recombination_rate}\n")
    
    with open(os.path.join(output_dir, file_name), 'w') as f:
        f.write(parameters)


# Function to save tree sequences to Gzip format
def save_tree_sequences(tree, output_format, output_dir, file_prefix):
    """Save the tree sequences in the specified format."""
    if output_format == 'vcf':
        vcf_file_path = os.path.join(output_dir, f"{file_prefix}.vcf")
        with open(vcf_file_path, 'w') as output_file:
            tree.write_vcf(output_file)

        # Save as Gzip
        with open(vcf_file_path, 'rb') as f_in:
            with gzip.open(vcf_file_path + '.gz', 'wb') as f_out:
                f_out.writelines(f_in)
        os.remove(vcf_file_path)  # Remove the original file after compression

    else:  # For tree sequence format
        ts_file_path = os.path.join(output_dir, f"{file_prefix}.ts")
        tree.dump(ts_file_path)

        # Save as Gzip
        with open(ts_file_path, 'rb') as f_in:
            with gzip.open(ts_file_path + '.gz', 'wb') as f_out:
                f_out.writelines(f_in)
        os.remove(ts_file_path)  # Remove the original file after compression

# Function to run a single simulation
def run_single_simulation(seed, sim_id, output_format, output_dir, demography_fromdata, sample_size, L):
    """Run a single simulation and save the results."""
    # Set the seed for reproducibility
    np.random.seed(seed)
    
    population_times = get_population_time(num_time_points)
    smooth_pop_sizes = sample_population_size(num_time_points, demography_fromdata)

    beta_alpha, nearly_kingman_alpha, mutation_rate, recombination_rate = sample_random_params()
    
    # Run simulations
    kingman_tree = simulate_kingman_coalescent(population_times, smooth_pop_sizes, L, recombination_rate, sample_size)
    beta_tree = simulate_beta_coalescent(beta_alpha, population_times, smooth_pop_sizes, L, recombination_rate, sample_size)
    nearly_kingman_tree = simulate_beta_coalescent(nearly_kingman_alpha, population_times, smooth_pop_sizes, L, recombination_rate, sample_size)
    
    #mutate trees
    kingman_tree_with_mutations = mutate_tree_sequence(kingman_tree, mutation_rate)
    beta_tree_with_mutations = mutate_tree_sequence(beta_tree, mutation_rate)
    nearly_kingman_tree_with_mutations = mutate_tree_sequence(nearly_kingman_tree, mutation_rate)

    # Save parameters and tree sequences
    file_suffix_kingman = f"sim_{sim_id}_seed_{seed}"  # Use sim_id instead of seed for the filename
    file_suffix_alpha = f"sim_{sim_id}_seed_{seed}_alpha_{round(beta_alpha, 2)}"  # Use sim_id instead of seed for the filename
    file_suffix_nearlykingman = f"sim_{sim_id}_seed_{seed}_alpha_{round(nearly_kingman_alpha, 2)}"  # Use sim_id instead of seed for the filename
    save_parameters(seed, sim_id, beta_alpha, nearly_kingman_alpha, mutation_rate, recombination_rate, output_dir, f"{file_suffix_kingman}_params.txt")
    save_tree_sequences(kingman_tree_with_mutations, output_format, output_dir, f"kingman_{file_suffix_kingman}")
    save_tree_sequences(beta_tree_with_mutations, output_format, output_dir, f"beta_{file_suffix_alpha}")
    save_tree_sequences(nearly_kingman_tree_with_mutations, output_format, output_dir, f"nearly_kingman_{file_suffix_nearlykingman}")


# Main function to execute the simulation process
def main():
    parser = create_parser()
    args = parser.parse_args()
    
    # Create the output directory if it does not exist
    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)
    
    # Run a single simulation based on provided arguments
    run_single_simulation(args.seed, args.sim_id, args.output_format, args.output_dir, demography_df, args.sample_size, args.length)

if __name__ == '__main__':
    main()




mv ~/.config ~/.config.backup_2
mv ~/.local ~/.local.backup_2
mv ~/.cache ~/.cache.backup_2