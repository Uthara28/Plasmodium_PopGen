
# Install and load packages
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
library(dplyr)

if (!requireNamespace("tidyr", quietly = TRUE)) {
  install.packages("tidyr")
}
library(tidyr)

setwd("/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/VCFs/vcf_gz/Samplemd_files")

Pf7_md_fws_res<-read.table("/data/proj2/home/students/u.srinivasan/Plasmodium_us/Inputs/Pf7/CRAM_pf7/Pf7_md_fws_res_loc_country_corr.txt",header=T, sep = "\t",row.names = NULL)


Samples_for_vcf_cam <- dplyr::filter(Pf7_md_fws_res, Fws > 0.95 & QC_pass== "True") %>% 
                   dplyr::filter(Country=="Cambodia") %>% 
                    dplyr::select("Sample")



Samples_for_vcf_cam.thai.viet <- dplyr::filter(Pf7_md_fws_res, Fws > 0.95 & QC_pass== "True") %>% 
                   dplyr::filter(Country=="Cambodia"|Country=="Thailand"|Country=="VietNam") 
nrow(Samples_for_vcf_cam.thai.viet)      
             
SamplesIds_for_vcf_cam.thai.viet<- Samples_for_vcf_cam.thai.viet  %>% dplyr::select("Sample")

nrow(SamplesIds_for_vcf_cam.thai.viet)

#Write to table

write.table(Samples_for_vcf_cam, file = "SamplesIds_for_vcf_cam.txt",sep = "\t", quote = FALSE,row.names = FALSE)

#write sample details and sample ids to table from cambodia, thailand vietnam
write.table(Samples_for_vcf_cam.thai.viet, file = "Samplesmd_for_vcf_cam.thai.viet.txt",sep = "\t", quote = FALSE,row.names = FALSE)
write.table(SamplesIds_for_vcf_cam.thai.viet, file = "SamplesIds_for_vcf_cam.thai.viet.txt",sep = "\t", quote = FALSE,row.names = FALSE)

