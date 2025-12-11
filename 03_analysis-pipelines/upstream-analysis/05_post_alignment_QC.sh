#!/bin/bash

# Directory containing your sorted BAM files
ALIGN_DIR="../../02_data/genome-alignment"

# Output directory for QC metrics
QC_DIR="../../04_results/post_alignment_QC"
mkdir -p "$QC_DIR"

echo "Starting post-alignment QC..."

# Loop through all sorted BAM files
for bam in "$ALIGN_DIR"/*.sorted.bam; do
    sample=$(basename "$bam" .sorted.bam)

    echo "QC for $sample ..."

    # 1. Basic flagstat: overall mapping stats
    samtools flagstat "$bam" > "$QC_DIR/${sample}.flagstat.txt"

    # 2. Stats: read lengths, coverage, insert size (SE = only read length)
    samtools stats "$bam" > "$QC_DIR/${sample}.samtools_stats.txt"

    # 3. idxstats: chromosome-level distribution
    samtools idxstats "$bam" > "$QC_DIR/${sample}.idxstats.txt"
done

echo "Samtools QC complete."

# Run MultiQC
echo "Running MultiQC..."
multiqc "$QC_DIR" -o "$QC_DIR/multiqc_alignment_report"

echo "All done! QC reports stored in $QC_DIR."
