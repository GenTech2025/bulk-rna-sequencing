# Load necessary libraries
library(tidyverse)
library(DESeq2)
library(ComplexHeatmap)
library(cowplot)

# Load the raw gene expression matrix and the annotation file for our data set
raw_data <- read_tsv("02_data/processed-data/counts.csv")
annotation <- read_csv("02_data/processed-data/metadata_run_sample_biosample.csv",col_names = TRUE)

# Check the column names of the raw_data tibble
column_names <- colnames(raw_data)

# Set the row names of the raw_data tibble as the Ensemble Gene IDs in this tibble its has been auto-named as "...1"
raw_data <- column_to_rownames(raw_data, '...1')

# Check the column names again
column_names <- colnames(raw_data)

# Arrange the annotation column
annotation <- arrange(annotation, Run)

# Check if the orders of the samples (Run Accessions) in the gene expression matrix and annotation file is the same
all(colnames(raw_data) == annotation$Run)









