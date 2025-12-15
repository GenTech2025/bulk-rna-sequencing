#!/bin/bash

BAM_DIR="../../02_data/genome-alignment"
ANNO_FILE="../../02_data/genome_annotation_files/Homo_sapiens.GRCh38.115.gtf"
OUT_DIR="../../02_data/processed-data"

# Create the output directory if it doesn't already exist
mkdir -p "$OUT_DIR"

# Quantify reads using featureCounts (single-end)
featureCounts -T 4 -t exon -g gene_id \
  -a "$ANNO_FILE" \
  -o "$OUT_DIR/raw_counts.txt" \
  "$BAM_DIR"/*.bam
