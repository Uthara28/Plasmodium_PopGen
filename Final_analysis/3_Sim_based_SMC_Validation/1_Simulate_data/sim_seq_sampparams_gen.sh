#!/bin/bash
# This line specifies that the script should be run using the Bash shell.
#To run have script.sh <out_dir> <beta/kingman> <list of mutation rates comma sep eg:1e-10,1e-9,1e-8> /
#<list of alphas e.g: 1.3,1.4> <number of simulation replicates> <number of sampled inds> <length of sequence>
# Create output directory if it doesn't exist
OUTPUT_DIR=$1
# Assign the first argument passed to the script to OUTPUT_DIR variable
if [ ! -d "$OUTPUT_DIR" ]; then
  # Check if the directory does not exist
  mkdir -p "$OUTPUT_DIR"
  # Create the output directory, including parent directories if necessary
fi


        # Seed for random number generation, ensuring reproducibility
MODEL=$2            # The second argument passed to the script, specifying the model ('kingman' or 'beta')
MUTATION_RATES=$3   # Third argument, a comma-separated string of mutation rates (e.g., "1e-4,1e-5,1e-6")
ALPHAS=$4           # Fourth argument, a comma-separated string of alpha values (for Beta model only, e.g., "1.2,1.3,1.4")

# Define simulation parameters
NUM_REPLICATES=$5  # Number of replicates for the simulation
SAMPLE_SIZE=$6     # Number of samples to simulate; 
LENGTH=$7    # Length of the sequence to simulate (1 million base pairs)
RECOMB_RATE=1e-7    # Recombination rate for the simulation
SEED=12345  

# Convert comma-separated lists into arrays
IFS=',' read -r -a MUTATION_RATES_ARRAY <<< "$MUTATION_RATES"
# Split the mutation rates string into an array using ',' as a delimiter

# Check if model is provided correctly
if [ -z "$MODEL" ]; then
  echo "Please provide a model ('kingman' or 'beta')."
  exit 1  # Exit the script if the model is not provided
fi

# If model is Beta, handle alpha values
if [ "$MODEL" == "beta" ]; then
  IFS=',' read -r -a ALPHAS_ARRAY <<< "$ALPHAS"
  # Split the alpha values string into an array using ',' as a delimiter
fi

# Function to run the simulation for a given mutation rate and alpha (if applicable)
run_simulation() {
  local mutation_rate=$1  # Assign the first argument (mutation rate) to a local variable
  local alpha=$2          # Assign the second argument (alpha value) to a local variable
  local output_dir        # Declare a local variable to store the output directory path
  
  echo "Model: $MODEL"
  echo "Mutation rate: $mutation_rate"
  echo "Alpha/Growth rate  (if Beta model): $alpha"
  echo "Outdir: $output_dir"

  if [ "$MODEL" == "kingman" ]; then
    # If the model is 
    output_dir="$OUTPUT_DIR/kingman/m${mutation_rate}"  # Define the output directory path for Kingman model
    mkdir -p "$output_dir"  # Create the output directory if it does not exist
    python3 /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/msprime_sims/scripts/sim_sequence_samplparams.py \
      --output_dir "$output_dir" --seed "$SEED" \
      --sample_size "$SAMPLE_SIZE" --length "$LENGTH" --recombination_rate "$RECOMB_RATE" \
      --num_replicates "$NUM_REPLICATES" --model "kingman" --mutation_rate "$mutation_rate"
    # Execute the Python simulation script for the Kingman model with the specified parameters
  elif [ "$MODEL" == "beta" ]; then
    # If the model is Beta
    output_dir="$OUTPUT_DIR/beta/m${mutation_rate}/alpha${alpha}"  # Define output directory path for Beta model
    mkdir -p "$output_dir"  # Create the output directory if it does not exist
    python3 /data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/msprime_sims/scripts/sim_sequence_samplparams.py \
      --output_dir "$output_dir" --seed "$SEED" \
      --sample_size "$SAMPLE_SIZE" --length "$LENGTH" --recombination_rate "$RECOMB_RATE" \
      --num_replicates "$NUM_REPLICATES" --model "beta" --alpha "$alpha" --mutation_rate "$mutation_rate"
    # Execute the Python simulation script for the Beta model with the specified parameters
  else
    echo "Unknown model: $MODEL"
    exit 1  # Exit the script if an unknown model is specified
  fi
}

# If the model is Kingman, only loop over mutation rates
if [ "$MODEL" == "kingman" ]; then
  export -f run_simulation  # Export the run_simulation function to be used by parallel
  export MODEL OUTPUT_DIR SEED SAMPLE_SIZE LENGTH RECOMB_RATE NUM_REPLICATES  # Export required variables

  # Run simulations in parallel across mutation rates
  parallel run_simulation ::: "${MUTATION_RATES_ARRAY[@]}"


# If the model is Beta, loop over both mutation rates and alpha values
elif [ "$MODEL" == "beta" ]; then
  export -f run_simulation  # Export the run_simulation function to be used by parallel
  export MODEL OUTPUT_DIR SEED SAMPLE_SIZE LENGTH RECOMB_RATE NUM_REPLICATES  # Export required variables

  # Run simulations in parallel across both mutation rates and alpha values
  parallel run_simulation ::: "${MUTATION_RATES_ARRAY[@]}" ::: "${ALPHAS_ARRAY[@]}"
fi

echo "Simulations completed!"  # Print a completion message when all simulations have finished
