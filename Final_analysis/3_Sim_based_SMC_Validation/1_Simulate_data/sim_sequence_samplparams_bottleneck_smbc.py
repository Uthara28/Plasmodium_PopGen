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
    parser.add_argument('--model', type=str, choices=['kingman', 'beta', 'beta_demography'], required=True, 
                        help='Choose between Kingman, Beta Coalescent, or Beta with Demography.')

    # Custom mutation rates as an argument
    parser.add_argument('--mutation_rate', type=float, required=True,
                        help="Value of mutation rate (passed from mutation rate array).")

    # Add --alpha argument conditionally
    parser.add_argument('--alpha', type=float, default=1.9, help='Value of alpha (only required for Beta model).')

    return parser

# Demographic data from user input
demography_data = {
    'years_ago': [20.91, 27.04, 34.98, 45.23, 58.50, 75.66, 97.86, 126.56, 163.69, 211.70,
                  273.81, 354.12, 457.99, 592.34, 766.09, 990.80, 1281.44, 1657.32, 2143.46, 2772.20],
    'Ne_log10': [3.88, 4.43, 4.43, 4.70, 4.70, 4.70, 4.70, 4.69, 4.69, 4.69,
                 4.69, 4.68, 4.68, 4.43, 4.43, 4.06, 4.06, 3.11, 3.11, 3.86]
}

demography_df = pd.DataFrame(demography_data)
num_time_points = len(demography_df)

# Function to generate population times
def get_population_time(demography_df):
    divided_years = demography_df['years_ago'] / 0.16  # Convert time to generations
    return divided_years.sort_values()

def sample_population_size(demography_df):
    return 10 ** demography_df['Ne_log10']

# Function to simulate Beta Coalescent with demography and save as text
def simulate_beta_replicate_with_demography(args):
    num_replicates, L, r, m, sample_size, output_dir, alpha, seed = args

    for i in range(num_replicates):
        rs = (seed + 1)**2 + i  # Setting the random seed
        np.random.seed(rs)
        population_times = get_population_time(demography_df)
        smooth_pop_sizes = sample_population_size(demography_df)

        demography_model = msprime.Demography()
        demography_model.add_population(initial_size=smooth_pop_sizes.iloc[0])
        for time, size in zip(population_times[1:], smooth_pop_sizes[1:]):
            demography_model.add_population_parameters_change(time=time, initial_size=size)
        
        ts = msprime.sim_ancestry(samples=sample_size, recombination_rate=r, sequence_length=L,
                                  demography=demography_model, ploidy=1, 
                                  model=msprime.BetaCoalescent(alpha=alpha), random_seed=rs)
        mts = msprime.sim_mutations(ts, rate=m, random_seed=rs)
        
        filename = os.path.join(output_dir, f"Tutorial_5_D_alpha{alpha}mu{m}r{r}x{i+1}L{L}.txt")
        with open(filename, "w") as f:
            for variant in mts.variants():
                f.write(f"{variant.site.position} {variant.genotypes.tolist()}\n")

def main():
    parser = create_parser()
    args = parser.parse_args()

    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)

    pool = multiprocessing.Pool()

    if args.model == 'kingman':
        pool_args = [(args.num_replicates, args.length, args.recombination_rate, args.mutation_rate, args.sample_size, args.output_dir, args.seed)]
        pool.map(simulate_kingman_replicate, pool_args)

 
    elif args.model == 'beta':
        pool_args = [(args.num_replicates, args.length, args.recombination_rate, args.mutation_rate, args.sample_size, args.output_dir, args.alpha, args.seed)]
        pool.map(simulate_beta_replicate_with_demography, pool_args)

    pool.close()
    pool.join()

if __name__ == '__main__':
    main()
