#!/usr/bin/env Rscript

###################
# Source function #
###################
library(eSMC2, lib.loc="/data/proj2/home/students/u.srinivasan/R/library")
library(BB, lib.loc="/data/proj2/home/students/u.srinivasan/R/library")

########
# Script #
########

# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
HS <- 40
file_path <- args[1]  # Get the VCF file path
out_dir <- args[2]
mut_rate <- args[3]

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

HS <- 40
M <- 8
NC <- 1
r <- 1e-7 # Recombination rate

# Function to get the first 8 and last two row indices
get_8_and_last_two_row_indices <- function(mat) {
    num_rows <- nrow(mat)
    if (num_rows < 2) {
        stop('The matrix must have at least two rows.')
    }
    first_eight <- 1:8
    last_two_indices <- (num_rows - 1):num_rows
    all_indices <- c(first_eight, last_two_indices)
    return(all_indices)
}

# Process the VCF data
Os <- eSMC2::Process_vcf_data(file_path)

# Select specific rows from the data
eight_last_two <- get_8_and_last_two_row_indices(Os)
Os <- Os[eight_last_two,]

#rho <- 1e-7 / mut_rate  # or however rho is calculated
rho<-1

print(paste("rho:", format(rho, scientific = TRUE, digits = 5)))

# Run the eSMC2 model
results <- eSMC2(
    n = HS,
    rho = rho,
    Os,
    BoxP = c(3, 3),
    Boxr = c(1, 1),
    pop = FALSE,
    SB = FALSE,
    SF = FALSE,
    Rho = TRUE,
    NC = NC,
    maxit = 50,
    FAST = FALSE,
    LH_opt = TRUE,
    Big_Window = TRUE
)

# Save individual results to an RDS file in the same directory
output_file <- file.path(out_dir, paste0(basename(file_path), '.rds'))
cat('Saving results to:', output_file, '\n')
saveRDS(results, output_file)
