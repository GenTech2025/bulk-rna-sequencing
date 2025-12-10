#!/bin/bash

# Input FASTQ directory
FASTQ_DIR="../../02_data"

# Output directory for trimmed FASTQs + reports
OUT_DIR="../../02_data/trimmed-reads"
mkdir -p "$OUT_DIR"

# Number of threads for each fastp job
THREADS=8

echo "Starting trimming for all samples..."

# Loop through all *.fastq.gz files
for fq in "$FASTQ_DIR"/*.fastq.gz; do
    
    # Extract sample name (remove .fastq.gz)
    sample=$(basename "$fq" .fastq.gz)

    echo "Trimming $sample ..."

    fastp \
        -i "$fq" \
        -o "$OUT_DIR/${sample}.trim.fastq.gz" \
        -q 20 \                # trim low-quality tail below Q20
        -l 20 \                # discard reads shorter than 20bp
        --trim_poly_x \        # trim poly-A/T/G/C tails
        --detect_adapter_for_pe \  # harmless for SE; helps detect adapters
        --thread "$THREADS" \
        --html "$OUT_DIR/${sample}.fastp.html" \
        --json "$OUT_DIR/${sample}.fastp.json"

    echo "Finished trimming $sample"
done

echo "All samples trimmed successfully."

