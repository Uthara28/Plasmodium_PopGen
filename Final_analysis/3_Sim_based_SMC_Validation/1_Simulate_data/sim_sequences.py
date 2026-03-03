import msprime
import numpy as np  # Importing NumPy for numerical operations
import os  # Importing os for operating system functionalities
import argparse  # Importing argparse for command-line argument parsing
import pandas as pd  # Importing pandas for DataFrame manipulation
import zipfile  # Importing zipfile for creating zip archives
import gzip
from scipy.interpolate import interp1d
import matplotlib.pyplot as plt
import tskit as ts    


#Set recombination rates, mutation rates, and alpha params

R=1e-07

#M=1e-04
#M=1e-05
#M=1e-06
M=1e-07
#M=1e-08
#M=1e-09
#M=1e-10

alpha=1

def kingman_constant(Ne=10**4, L=1_000_000, demo="const", r=R, m=M,num_replicates=100, sample_size=10):
    """
    Simulate tree sequences using the Kingman Coalescent model with a constant demography
    and save the results as VCF and tree sequence (ts) files for each replicate.
    
    Parameters:
    - Ne (int): Effective population size (default: 10^4).
    - L (int): Sequence length (default: 1,000,000).
    - demo (str): Demography name for file labeling (default: "const").
    - r (float): Recombination rate (default: 5e-8).
    - num_replicates (int): Number of replicates to simulate (default: 1).
    - sample_size (int): Sample size for the simulation (default: 10).
    - m (float): Mutation rate (default: 1e-7).
    
    Returns:
    - tree_sequence: The last simulated tree sequence.
    - demography: The demography model used for the simulation.
    """
    
    alpha = 2.0  # Kingman Coalescent corresponds to alpha = 2.0
    demography = msprime.Demography()
    demography.add_population(initial_size=Ne)

    # Initialize lists to hold filenames
    vcf_filenames = []
    ts_filenames = []
    
    for i in range(num_replicates):
        # Set a unique random seed for each replicate
        rs = (alpha + 1)**2 + i
        
        # Simulate the ancestry using the Kingman Coalescent model
        tree_sequence = msprime.sim_ancestry(
            samples=sample_size,
            recombination_rate=r,
            sequence_length=L,
            demography=demography,
            ploidy=1,
            random_seed=rs
        )
        
        # Simulate mutations on the tree sequence
        tree_sequence = msprime.sim_mutations(tree_sequence, rate=m, random_seed=rs)
        
        # Define filenames for VCF and tree sequence (ts) outputs
        vcf_filename = (
            f'/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/'
            f'msprime_sims/SINGER_in_out/recom_mutation_1e2/Constant_popsize/Inputs/'
            f'BetaCoal_{demo}_rep{i}_m{m}_r{r}_rs{rs}.vcf'
        )
        ts_filename = (
            f'/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/'
            f'msprime_sims/SINGER_in_out/recom_mutation_1e2/Constant_popsize/Inputs/'
            f'BetaCoal_{demo}_rep{i}_m{m}_r{r}_rs{rs}.ts'
        )
        
        # Save the tree sequence as VCF
        with open(vcf_filename, 'w') as vcffh:
            tree_sequence.write_vcf(
                vcffh,
                position_transform='legacy',
                individual_names=[f'spl{str(s)}' for s in range(sample_size)]
            )
        
        # Save the tree sequence to a file
        tree_sequence.dump(ts_filename)

        # Store filenames
        vcf_filenames.append(vcf_filename)
        ts_filenames.append(ts_filename)

    return tree_sequence, demography  # Return the last tree sequence and the demography model


import itertools

# Initialize lists to hold filenames
vcf_filenames = []
ts_filenames = []

L=1_000_000
r=5e-8
num_replicates=100
m=1e-07
Ne=10000

alpha = 2.0  # Kingman Coalescent corresponds to alpha = 2.0
demography = msprime.Demography()
demography.add_population(initial_size=Ne)

tree_sequence=[]

for i in range(10):
        
    # Set a unique random seed for each replicate
    rs = (alpha + 1)**2 + i
        
    # Simulate the ancestry using the Kingman Coalescent model
    tree_sequence = msprime.sim_ancestry(
            samples=10,
            recombination_rate=r,
            sequence_length=L,
            demography=demography,
            ploidy=1,
            random_seed=rs)

# Simulate mutations on the tree sequence
tree_sequence = msprime.sim_mutations(tree_sequence, rate=m, random_seed=rs)


def beta_constant(alpha, demo="Const" ,Ne=10**4, L=1_000_000, r=R, m=M, num_replicates=100, sample_size=10):
    """
    Simulate tree sequences using the Beta Coalescent model with a constant alpha and
    save the results as VCF and tree sequence (ts) files for each replicate.
    
    Parameters:
    - alpha (float): Beta coalescent alpha parameter.
    - Ne (int): Effective population size (default: 10^4).
    - L (int): Sequence length (default: 1,000,000).
    - r (float): Recombination rate (default: 5e-8).
    - num_replicates (int): Number of replicates to simulate (default: 5).
    - sample_size (int): Sample size for the simulation (default: 10).
    - m (float): Mutation rate (default: 1e-7).
    
    Returns:
    - tree_sequence: The last simulated tree sequence.
    - demography: The demography model used for the simulation.
    """
    
    alpha = 1.5  # Set alpha for the Beta coalescent
    demography = msprime.Demography()
    demography.add_population(initial_size=Ne)

    # Initialize lists to hold filenames
    vcf_filenames = []
    ts_filenames = []
    
    for i in range(num_replicates):
        # Set a unique random seed for each replicate
        rs = (alpha + 1)**2 + i
        
        # Simulate the ancestry using the Beta Coalescent model
        tree_sequence = msprime.sim_ancestry(
            samples=sample_size,
            recombination_rate=r,
            sequence_length=L,
            demography=demography,
            ploidy=1,
            model=msprime.BetaCoalescent(alpha=alpha),
            random_seed=rs
        )
        
        # Simulate mutations on the tree sequence
        tree_sequence = msprime.sim_mutations(tree_sequence, rate=m, random_seed=rs)
        
        # Define filenames for VCF and tree sequence (ts) outputs
        vcf_filename = (
            f'/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/'
            f'msprime_sims/SINGER_in_out/recom_mutation_1e2/Constant_popsize/Inputs/'
            f'BetaCoal_{demo}_rep{i}_m{m}_r{r}_rs{rs}.vcf'
        )
        ts_filename = (
            f'/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/'
            f'msprime_sims/SINGER_in_out/recom_mutation_1e2/Constant_popsize/Inputs/'
            f'BetaCoal_{demo}_rep{i}_m{m}_r{r}_rs{rs}.ts'
        )
        
        # Save the tree sequence as VCF
        with open(vcf_filename, 'w') as vcffh:
            tree_sequence.write_vcf(
                vcffh,
                position_transform='legacy',
                individual_names=[f'spl{str(s)}' for s in range(sample_size)]
            )
        
        # Save the tree sequence to a file
        tree_sequence.dump(ts_filename)

        # Store filenames
        vcf_filenames.append(vcf_filename)
        ts_filenames.append(ts_filename)

    return tree_sequence, demography  # Return the last tree sequence and the demography model

tree, demo=beta_constant(alpha=1.5)