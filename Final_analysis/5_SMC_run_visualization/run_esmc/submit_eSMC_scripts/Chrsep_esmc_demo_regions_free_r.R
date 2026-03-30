###################
# Source function #
###################
library("eSMC2")
library("BB")

#########
# Script #
########

#Parse command-line arguments
args <- commandArgs(trailingOnly = TRUE)
mhs_path <- args[1]  # Get the mhsf file path
out_dir <- args[2]
mut_rate <- as.numeric(args[3])
r <- as.numeric(args[4]) 

#define input paths
mhs_name <- basename(mhs_path)  # Get the mhs file name

No_haps <- as.numeric(sub(".*top([0-9]+)_.*", "\\1", mhs_name))


M <- 2*No_haps
NC <- 1 # Set the variables
HS <- 32 #hidden states
rho <- r / mut_rate  # recom/mut ratio


mhs_dir<-dirname(mhs_path)


M <- 2*No_haps
NC <- 1
#mu <-  2.45e-10 # Mutation rate- lower per gen from the nature paper

#r <-1.04167e-7
HS <- 40 # Hidden states



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

rho<-1
print(paste("rho:", format(rho, scientific = TRUE, digits = 5)))

# Run the eSMC2 model
results <- eSMC2(
  n = HS,
  rho = rho ,
  Os, 
  BoxP = c(3, 3),
  Boxr=c(2,2),
  pop = FALSE,
  SB = FALSE,
  SF = FALSE,
  Rho = TRUE,   #: True to estimate recombination rate
  NC = NC,
  maxit = 50,
  pop_vect=rep(4,(HS/4)),
  FAST = FALSE,  #FALSE to not run 'fast' mode (baumwelch)
  LH_opt = TRUE,   #TRUE tu maximize likelihood and not perform the baum-welch algorithm
  Big_Window = T
)
# Save individual results to an RDS file in the same directory
output_file <- file.path(out_dir, paste0(basename(mhs_path), '.rds'))

cat('Saving results to:', output_file, '\n')

saveRDS(results, output_file)