import sys
import os
import msprime
import numpy as np
import argparse
import pandas as pd  
import multiprocessing

# Function to create an argument parser
def create_parser():
    parser = argparse.ArgumentParser(description="Simulate coalescent processes using msprime.")
    
    # General arguments
    parser.add_argument('--output_dir', type=str, default="./output", 
                        help='Output directory for tree sequence or VCF files.')
    parser.add_argument('--seed', type=int, required=True, help='Random seed for reproducibility.')
    parser.add_argument('--sample_size', type=int, required=True, help='Number of samples for the simulation.')
    parser.add_argument('--length', type=int, default=1_000_000, help='Sequence length (in base pairs).')
    parser.add_argument('--recombination_rate', type=float, default=1e-7, help='Fixed recombination rate.')
    parser.add_argument('--num_replicates', type=int, default=100, help='Number of replicates for the simulation.')
    
    # Model selection argument
    parser.add_argument('--model', type=str, choices=['kingman', 'beta'], required=True, 
                        help='Choose between Kingman or Beta Coalescent model.')

    # Custom mutation rates as an argument
    parser.add_argument('--mutation_rate', type=float, required=True,
                        help="Value of mutation rate (passed from mutation rate array).")

    # Add --alpha argument conditionally
    parser.add_argument('--alpha', type=float, default=1.9, help='Value of alpha (only required for Beta model).')

    return parser

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

# User-defined parameters
num_time_points = 39  # Number of time points for demographic changes

# Function to generate population times
def get_population_time(num_time_points):
    """Generate population times."""
    divided_years = demography_df['years_ago'] / 0.16  # Divide years_ago by generation time
    divided_years=divided_years.sort_values()
    return  divided_years # Select evenly spaced time points in generations

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


def simulate_kingman_replicate(args):
    num_replicates, L, r, m, sample_size, output_dir, seed = args
    
    for i in range(num_replicates):
        rs = (seed + 1)**2 + i  # Setting the random 
        np.random.seed(rs)
        population_times = get_population_time(num_time_points)
        smooth_pop_sizes = sample_population_size(num_time_points, demography_df)

        demography_model = msprime.Demography()
        demography_model.add_population(initial_size=smooth_pop_sizes[0])
        for time, size in zip(population_times[1:], smooth_pop_sizes[1:]):
            demography_model.add_population_parameters_change(time=time, initial_size=size)
        
        tree_sequence = msprime.sim_ancestry(samples=sample_size, recombination_rate=r, sequence_length=L,
                                            demography=demography_model,
                                            ploidy=1, random_seed=rs)
        tree_sequence = msprime.sim_mutations(tree_sequence, rate=m, random_seed=rs)
        ratio=float(r/m)
        vcf_filename = os.path.join(output_dir, f'Kingman_bottleneck_rep{i}_m{m}_ratio{ratio}_rs{rs}.vcf')
        ts_filename = os.path.join(output_dir, f'Kingman_bottleneck_rep{i}_m{m}_ratio{ratio}_rs{rs}.ts')

        with open(vcf_filename, 'w') as vcffh:
            tree_sequence.write_vcf(vcffh, position_transform='legacy',
                                    individual_names=[f'spl{str(s)}' for s in range(sample_size)])
        tree_sequence.dump(ts_filename)

def simulate_beta_replicate(args):
    num_replicates,L, r, m, sample_size, output_dir, alpha, seed = args

    for i in range(num_replicates):
        rs = (seed + 1)**2 + i  # Setting the random seed
        np.random.seed(rs)
        population_times = get_population_time(num_time_points)
        smooth_pop_sizes = sample_population_size(num_time_points, demography_df)

        demography_model = msprime.Demography()
        demography_model.add_population(initial_size=smooth_pop_sizes[0])
        for time, size in zip(population_times[1:], smooth_pop_sizes[1:]):
            demography_model.add_population_parameters_change(time=time, initial_size=size)
        
        tree_sequence = msprime.sim_ancestry(samples=sample_size, recombination_rate=r, sequence_length=L,
                                            demography=demography_model,
                                            ploidy=1, model=msprime.BetaCoalescent(alpha=alpha), 
                                            random_seed=rs)
        tree_sequence = msprime.sim_mutations(tree_sequence, rate=m, random_seed=rs)
        ratio=float(r/m)
        vcf_filename = os.path.join(output_dir, f'Beta_bottleneck_rep{i}_m{m}_ratio{ratio}_rs{rs}.vcf')
        ts_filename = os.path.join(output_dir, f'Beta_bottleneck_rep{i}_m{m}_ratio{ratio}_rs{rs}.ts')

        with open(vcf_filename, 'w') as vcffh:
            tree_sequence.write_vcf(vcffh, position_transform='legacy',
                                    individual_names=[f'spl{str(s)}' for s in range(sample_size)])
        tree_sequence.dump(ts_filename)

def main():
    parser = create_parser()
    args = parser.parse_args()

    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)

    pool = multiprocessing.Pool()

    if args.model == 'kingman':
        # For Kingman model, only mutation rate is needed
        
        pool_args = [(args.num_replicates, args.length, args.recombination_rate, args.mutation_rate, args.sample_size, args.output_dir, args.seed)]
        pool.map(simulate_kingman_replicate, pool_args)

    elif args.model == 'beta':
        # For Beta model, alpha must be provided
        if args.alpha is None:
            raise ValueError("Alpha parameter must be provided for Beta coalescent model.")
        pool_args = [(args.num_replicates, args.length, args.recombination_rate, args.mutation_rate, args.sample_size, args.output_dir, args.alpha, args.seed)]
        pool.map(simulate_beta_replicate, pool_args)

    pool.close()
    pool.join()

if __name__ == '__main__':
    main()
