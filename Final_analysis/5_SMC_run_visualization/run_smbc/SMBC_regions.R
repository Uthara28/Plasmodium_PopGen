#!/usr/bin/env Rscript

###################
# Source function #
###################
library(eSMC2,lib.loc="/data/proj2/home/students/u.srinivasan/R/library")
library(BB,lib.loc="/data/proj2/home/students/u.srinivasan/R/library")

########
# Script #
########
packageVersion("eSMC2")

# Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)

mhs_path <- args[1]  # Get the mhsf file path
out_dir <- args[2]
mut_rate <- as.numeric(args[3])
r <- as.numeric(args[4]) 


# Set the variables
HS <- 32 #hidden states
M <-8 #num haplotypes in mhs
NC <- 1 #No. of chromz
rho <- r / mut_rate  # recom/mut ratio

#define input paths
mhs_name <- basename(mhs_path)  # Get the mhs file name
mhs_dir<-dirname(mhs_path)


# Validate arguments
if (!file.exists(mhs_path)) {
    stop(paste('mhs file does not exist:', mhs_path))
}
if (!dir.exists(out_dir)) {
    stop(paste('Output directory does not exist:', out_dir))
}

# Define the function to get odd and last two row indices
get_odd_and_last_two_row_indices <- function(mat) {
  num_rows <- nrow(mat)
  if (num_rows < 2) {
    stop("The matrix must have at least two rows.")
  }
  odd_indices <- seq(1, num_rows - 2, by = 2)
  last_two_indices <- (num_rows - 1):num_rows
  all_indices <- c(odd_indices, last_two_indices)
  return(all_indices)
}
# Construct the file name
file_name <- paste(mhs_name)

# Read data
Os <- Get_real_data(mhs_dir, M, file_name, delim = "\t")

# Select specific rows from the data
odd_and_last_two_row_indices <- get_odd_and_last_two_row_indices(Os)
Os <- Os[odd_and_last_two_row_indices,] #choose only the alternate haplotypes

print(Os[,1:5])

rho<-10

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
output_file <- file.path(out_dir, paste0(basename(mhs_path), '.rds'))
cat('Saving results to:', output_file, '\n')
saveRDS(results, output_file)


