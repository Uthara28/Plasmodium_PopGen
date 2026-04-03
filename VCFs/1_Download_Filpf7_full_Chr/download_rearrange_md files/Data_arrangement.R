
# Install and load packages
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
library(dplyr)

if (!requireNamespace("tidyr", quietly = TRUE)) {
  install.packages("tidyr")
}
library(tidyr)

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}
library(ggplot2)

if (!requireNamespace("gridExtra", quietly = TRUE)) {
  install.packages("gridExtra")
}
library(gridExtra)

if (!requireNamespace("reshape2", quietly = TRUE)) {
  install.packages("reshape2")
}
library(reshape2)

#Set working directory

setwd("/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/Pf7")

#Step1: obtain and save files locally

#PF7 Sample metadata

file_url <- "https://www.malariagen.net/sites/default/files/Pf7_samples.txt"
# Replace the following placeholder with the desired local path to save the file
local_path <- "/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/Pf7/Pf7_samples.txt"
# Construct the wget command
wget_command <- paste("wget", "-O", shQuote(local_path), shQuote(file_url))
# Run the wget command
system(wget_command)

#FWS data

file_url <- "https://www.malariagen.net/sites/default/files/Pf7_fws.txt"
# Replace the following placeholder with the desired local path to save the file
local_path <- "/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/Pf7/Pf7_fws.txt"
# Construct the wget command
wget_command <- paste("wget", "-O", shQuote(local_path), shQuote(file_url))
# Run the wget command
system(wget_command)

#Resistence data

file_url <- "https://www.malariagen.net/sites/default/files/Pf7_inferred_resistance_status_classification.txt"
# Replace the following placeholder with the desired local path to save the file
local_path <- "/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/Pf7/Pf7_res.txt"
# Construct the wget command
wget_command <- paste("wget", "-O", shQuote(local_path), shQuote(file_url))
# Run the wget command
system(wget_command)


#Read as table into R
Pf7_md<-read.table("/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/Pf7/Pf7_samples.txt", header=T, sep = "\t", quote = "", fill = TRUE)
Pf7_fws<-read.table("/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/Pf7/Pf7_fws.txt",header=T, sep = "\t", quote = "", fill = TRUE)
Pf7_res<-read.table("/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/Pf7/Pf7_res.txt", header=T, sep = "\t", quote = "", fill = TRUE)

#attach fws data to metadata using "leftjoin"
Pf7_md_fws_res<-left_join(as.data.frame(Pf7_md),as.data.frame(Pf7_fws), by="Sample") %>% left_join(as.data.frame(Pf7_res),by="Sample") %>% na.omit()

#save combined metadata and fws
# Specify quote = FALSE in the write.table call
write.table(Pf7_md_fws_res, file = "Pf7_md_fws_res.txt", sep = "\t", quote = FALSE)

