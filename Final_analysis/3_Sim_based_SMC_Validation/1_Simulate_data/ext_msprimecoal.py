#!/usr/bin/env python
import argparse
import os
import subprocess
import concurrent.futures
import sys
import os


# Command to run the script: 
# python run_simulations.py --simulations <number_of_simulations> --cpus <number_of_cpus> --internal <path_to_internal_script> --output_dir <output_directory> --output_format <vcf_or_ts> --sample_size <sample_size> --length <length>

# Function to create argument parser for the external script
def create_parser():
    parser = argparse.ArgumentParser(description="Run multiple simulations in parallel.")
    parser.add_argument('--simulations', type=int, required=True, help='Total number of simulations to run.')
    parser.add_argument('--cpus', type=int, default=1, help='Number of CPU cores to use for parallel processing.')
    parser.add_argument('--internal', type=str, required=True, help='Path to the internal script for simulation.')
    parser.add_argument('--output_dir', type=str, default="./output", help='Output directory for simulation files.')
    parser.add_argument('--output_format', type=str, choices=['vcf', 'ts'], default='vcf',
                        help='Output format for the simulation (either "vcf" or "ts").')
    parser.add_argument('--sample_size', type=int, required=True, help='Sample size for the simulation.')
    parser.add_argument('--length', type=int, required=True, help='Length parameter for the simulation.')
    return parser

# Function to generate seeds based on a base number and simulation ID
def generate_seeds(num_simulations, base_number=100):
    return [base_number + sim_id for sim_id in range(1, num_simulations + 1)]

# Function to run a single simulation by invoking the internal script
def run_simulation(seed, sim_id, internal_script, output_dir, output_format, sample_size, length):
    # Command to run the internal script using subprocess
    command = [
        "python3", internal_script,
        "--seed", str(seed),                # Pass the seed for reproducibility
        "--sim_id", str(sim_id),            # Pass the simulation number
        "--sample_size", str(sample_size),   # Pass the sample size
        "--length", str(length),             # Pass the length
        "--output_dir", output_dir,         # Output directory
        "--output_format", output_format     # Output format (vcf or ts)
    ]
    
    # Print progress for tracking
    print(f"Running simulation {sim_id} with seed {seed}...")

    # Execute the command and wait for it to finish
    subprocess.run(command, check=True)

# Main function to parallelize and run simulations
def main():
    parser = create_parser()
    args = parser.parse_args()

    # Create output directory if it doesn't exist
    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)

    # Generate seeds based on the base number and simulation ID
    seeds = generate_seeds(args.simulations)

    # Run simulations in parallel using multiple CPU cores
    with concurrent.futures.ProcessPoolExecutor(max_workers=args.cpus) as executor:
        # Submit tasks to run simulations in parallel, tracking sim_id and seed
        futures = [
            executor.submit(run_simulation, seed, sim_id, args.internal, args.output_dir, args.output_format, args.sample_size, args.length)
            for sim_id, seed in enumerate(seeds, start=1)  # sim_id starts from 1
        ]
        
        # Check for any exceptions that might occur during execution
        for future in concurrent.futures.as_completed(futures):
            try:
                future.result()  # Raise any exceptions that occurred during simulation
            except Exception as e:
                print(f"Simulation generated an exception: {e}")

    print(f"All simulations completed. Results saved in {args.output_dir}.")

if __name__ == "__main__":
    main()
