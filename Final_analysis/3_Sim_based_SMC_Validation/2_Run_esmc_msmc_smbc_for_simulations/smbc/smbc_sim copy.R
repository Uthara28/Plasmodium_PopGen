#!/usr/bin/env Rscript

###################
# Source function #
###################
library("eSMC2", lib.loc="/data/proj2/home/students/u.srinivasan/R/library")
library("BB", lib.loc="/data/proj2/home/students/u.srinivasan/R/library")########
# Script #
########

# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
file_path <- args[1]  # Get the VCF file path
out_dir <- args[2]


# Set the variables

mut_rate <- as.numeric(args[3])
in_path <- file_path
out_dir <- out_dir
file_name <- basename(file_path)  # Get the VCF file name

# Debugging output to validate paths
cat('Input Path:', in_path, '\n')
cat('Output Directory:', out_dir, '\n')
cat('VCF File Name:', file_name, '\n')

# Validate arguments
if (!file.exists(file_path)) {
    stop(paste('VCF file does not exist:', file_path))
}
if (!dir.exists(out_dir)) {
    stop(paste('Output directory does not exist:', out_dir))
}

M <- 
NC <- 1
r <- 1e-7 # Recombination rate
HS <- 40

# Function to get the first 8 and last two row indices
get_3_and_last_two_row_indices <- function(mat) {
    num_rows <- nrow(mat)
    if (num_rows < 2) {
        stop('The matrix must have at least two rows.')
    }
    first_three <- 1:3
    last_two_indices <- (num_rows - 1):num_rows
    all_indices <- c(first_three, last_two_indices)
    return(all_indices)
}

# Process the VCF data
Os <- eSMC2::Process_vcf_data(file_path)

# Select specific rows from the data
three_last_two <- get_3_and_last_two_row_indices(Os)
Os <- Os[three_last_two,]

rho <- 1e-7 / mut_rate  # or however rho is calculated

print(paste("rho:", format(rho, scientific = TRUE, digits = 5)))

# Run the eSMC2 model
results <- SMBC(
    n = HS,
    rho = rho,
    Os,
    BoxP = c(3, 3),
    Boxa = c(1.001, 1.999),
    pop = FALSE,
    alpha =1.9,
    B=T,
    ER=FALSE,
    ploidy=1,
    mu_real=mut_rate,
    pop_vect = rep(4,(HS/4)), #vector of hidden state sharing their population size parameter. Sum must be equal to hidden state number
    NC = NC,
    LH_opt = TRUE,
    Big_Window = TRUE
)

# Save individual results to an RDS file in the same directory
output_file <- file.path(out_dir, paste0(basename(file_path), '.rds'))
cat('Saving results to:', output_file, '\n')
saveRDS(results, output_file)


