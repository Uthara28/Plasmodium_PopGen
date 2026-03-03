import sys
import os
import msprime
import numpy as np
import argparse
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

def simulate_kingman_replicate(args):
    num_replicates, Ne, L, r, m, sample_size, output_dir, seed = args
    
    for i in range(num_replicates):
        rs = (seed + 1)**2 + i  # Setting the random seed

        demography = msprime.Demography()
        demography.add_population(initial_size=Ne)
        tree_sequence = msprime.sim_ancestry(samples=sample_size, recombination_rate=r, sequence_length=L,
                                            demography=demography,
                                            ploidy=1, random_seed=rs)
        tree_sequence = msprime.sim_mutations(tree_sequence, rate=m, random_seed=rs)
        ratio=float(r/m)
        vcf_filename = os.path.join(output_dir, f'Kingman_rep{i}_m{m}_ratio{ratio}_rs{rs}.vcf')
        ts_filename = os.path.join(output_dir, f'Kingman_rep{i}_m{m}_ratio{ratio}_rs{rs}.ts')

        with open(vcf_filename, 'w') as vcffh:
            tree_sequence.write_vcf(vcffh, position_transform='legacy',
                                    individual_names=[f'spl{str(s)}' for s in range(sample_size)])
        tree_sequence.dump(ts_filename)

def simulate_beta_replicate(args):
    num_replicates, Ne, L, r, m, sample_size, output_dir, alpha, seed = args

    for i in range(num_replicates):
        demography = msprime.Demography()
        demography.add_population(initial_size=Ne)
        rs = (seed + 1)**2 + i  # Setting the random seed
        tree_sequence = msprime.sim_ancestry(samples=sample_size, recombination_rate=r, sequence_length=L,
                                            demography=demography,
                                            ploidy=1, model=msprime.BetaCoalescent(alpha=alpha), 
                                            random_seed=rs)
        mts = msprime.sim_mutations(tree_sequence, rate=m, random_seed=rs)
        
        ratio=float(r/m)
        
        filename = os.path.join(output_dir, f"Tutorial_5_D_alpha{alpha}mu{m}r{r}ratio{ratio}x{i+1}L{L}.txt")
        with open(filename, "w") as f:
            for variant in mts.variants():
                f.write(f"{variant.site.position} {variant.genotypes.tolist()}\n")


def main():
    parser = create_parser()
    args = parser.parse_args()

    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)

    Ne = 10**4  # Effective population size

    pool = multiprocessing.Pool()

    if args.model == 'kingman':
        # For Kingman model, only mutation rate is needed
        pool_args = [(args.num_replicates, Ne, args.length, args.recombination_rate, args.mutation_rate, args.sample_size, args.output_dir, args.seed)]
        pool.map(simulate_kingman_replicate, pool_args)

    elif args.model == 'beta':
        # For Beta model, alpha must be provided
        if args.alpha is None:
            raise ValueError("Alpha parameter must be provided for Beta coalescent model.")
        pool_args = [(args.num_replicates, Ne, args.length, args.recombination_rate, args.mutation_rate, args.sample_size, args.output_dir, args.alpha, args.seed)]
        pool.map(simulate_beta_replicate, pool_args)

    pool.close()
    pool.join()

if __name__ == '__main__':
    main()
