#!/bin/bash

SAVE_DIR="../../02_data/genome_annotation_files"

mkidr -p "$SAVE_DIR"

# Download the Genome FASTA file
wget -P "$SAVE_DIR" \
 https://ftp.ensembl.org/pub/release-115/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa.gz

# Download the Annotation GTF file
wget -P "$SAVE_DIR" \
 https://ftp.ensembl.org/pub/release-115/gtf/homo_sapiens/Homo_sapiens.GRCh38.115.gtf.gz


# Navigate into the save directory
cd "$SAVE_DIR"

# Unzip for everything
gunzip *.gz
