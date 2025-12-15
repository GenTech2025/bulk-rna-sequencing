#!/bin/bash

# Create directory for the genome index
mkdir -p ../../02_data/genome-index

# Download the genome index
wget -P ../../02_data/genome-index https://genome-idx.s3.amazonaws.com/hisat/grch38_snptran.tar.gz

# Extract the index files so HISAT2 can use them
tar -xzvf ../../02_data/genome-index/grch38_snptran.tar.gz -C ../../02_data/genome-index