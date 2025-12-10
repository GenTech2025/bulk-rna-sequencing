#!/bin/bash

# Path to HISAT2 index prefix (change this to your downloaded index)
HISAT2_INDEX="../../02_data/genome-index/grch38_snp_tran/genome_snp_tran"

# Input directory containing trimmed fastq files
FASTQ_DIR="../../02_data/trimmed-reads"

# Output directory
OUT_DIR="../../02_data/genome-alignment"
mkdir -p "$OUT_DIR"

# Loop through all fastq files ending with .fastq.gz or .fq.gz
for fq in "$FASTQ_DIR"/*.fastq.gz; do
    sample=$(basename "$fq" .fastq.gz)   # extract sample name

    echo "Aligning $sample ..."

    # HISAT2 alignment → SAM → BAM → sorted BAM
    hisat2 -p 8 \
        -x "$HISAT2_INDEX" \
        -U "$fq" \
        --rna-strandness R \
        --summary-file "$OUT_DIR/${sample}.hisat2_summary.txt" \
        -S "$OUT_DIR/${sample}.sam"


    # Convert SAM → sorted BAM
    samtools view -@ 4 -bS "$OUT_DIR/${sample}.sam" | \
    samtools sort -@ 4 -o "$OUT_DIR/${sample}.sorted.bam"

    # Index BAM
    samtools index "$OUT_DIR/${sample}.sorted.bam"

    # Remove SAM to save space
    rm "$OUT_DIR/${sample}.sam"

    echo "Finished $sample"
done

echo "All samples aligned."
