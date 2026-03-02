args <- commandArgs(trailingOnly = TRUE)

# Check if the correct number of arguments are provided
if (length(args) != 2) {
    stop("Usage: Rscript process_vcf.R <vcf_file> <output_file>")
}

vcf_file <- args[1]
output_file <- args[2]

library(eSMC2)
library(BB)

# Process the VCF data
Os <- tryCatch({
    eSMC2::Process_vcf_data(vcf_file)
}, error = function(e) {
    stop(paste('Error processing VCF data:', e$message))
})

# Check if Os is a matrix and adjust as necessary
if (!is.matrix(Os)) {
    stop('Processed data is not a matrix. Check input VCF file format.')
}

# Print dimensions of Os for debugging
print(paste("Dimensions of Os:", paste(dim(Os), collapse = " x ")))

# Check if the number of rows is sufficient
if (nrow(Os) < 18) {
    stop("Insufficient number of rows in processed data. Expected at least 18 rows.")
}

Os <- Os[c(1:8, 17, 18),]
print("Processed subset of Os:")
print(Os[c(8:10),])  # Print first 3 rows for verification

# Process the VCF data

create_realinput_msmc2 = function(O, name, num = FALSE) {
            options(scipen = 999)

            # Convert the input to a matrix and get dimensions
            O = as.matrix(O)
            M = dim(O)[1] - 2  # Number of rows excluding last two
            n = dim(O)[2]      # Number of columns
            
            # Extract vector of positions (assumed to be in the last row)
            vect_opti = as.numeric(O[M + 2, ])
            # Remove the last row which contains positions
            O = O[-(M + 2), ]
            
            # Convert 1s and 0s to "A" and "T" if num is TRUE
            if (num) {
                for (seq in 1:M) {
                    O1 = as.character(O[seq, ])
                    Apos = which(O1 == "1")
                    Tpos = which(O1 == "0")
                    O1[Apos] = "A"
                    O1[Tpos] = "T"
                    O[seq, ] = O1
                }
            }

            # Initialize output matrix
            output = matrix(NA, nrow = length(vect_opti), ncol = 4)
            count = 0

            # Process each column to fill output
            for (p in 1:length(vect_opti)) {
                unique_alleles = unique(O[1:M, p])
                diff = length(unique_alleles)

                if (diff > 1) {  # Only consider columns with more than one unique allele
                    count = count + 1
                    output[count, 1] = 1  # First column is always 1
                    output[count, 2] = as.numeric(format(as.numeric(vect_opti[p]), scientific = FALSE))  # Position
                    output[count, 3] = as.integer(O[(M + 1), p])  # Allele count
                    
                    # Check if there are alleles to concatenate
                    alleles = O[1:M, p]
                    if (length(alleles) > 0) {
                        output[count, 4] = paste(alleles, collapse = "")  # Concatenate alleles
                    } else {
                        warning(sprintf("No alleles found for position %s in column %d", vect_opti[p], p))
                    }
                } else {
                    warning(sprintf("Not enough unique alleles for position %s in column %d", vect_opti[p], p))
                }
            }

            # Trim output to remove NA rows
            output = output[1:count, , drop = FALSE]

            # Check if output is not empty before writing to file
            if (nrow(output) > 0) {
                utils::write.table(output, file = paste(name, '.txt', sep = ''), quote = FALSE, row.names = FALSE, col.names = FALSE)
            } else {
                warning('No valid data to write to the output file.')
            }

            options(scipen = 0)
        }


create_realinput_msmc2(Os, output_file)
