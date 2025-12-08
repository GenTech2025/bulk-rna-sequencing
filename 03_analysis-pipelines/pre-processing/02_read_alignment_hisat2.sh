#!/usr/bin/env bash

# ====== EDIT THESE ======
GENOME_FA="../../data/preprocessing-data/Mus_musculus.GRCm39.dna_sm.primary_assembly.fa"
GTF="../../data/preprocessing-data/Mus_musculus.GRCm39.115.gtf"
INDEX_PREFIX="mm39_tran"              # name for index files to create
READS_DIR="../../data"           # where SRR* fastqs are (named SRR*_1.fastq.gz / SRR*_2.fastq.gz)
THREADS=8
STRAND="FR"                           # if unstranded, set STRAND="" and remove the option below

# ====== 1) Make splice/exon lists from the GTF (for RNA-seq-aware index) ======
hisat2_extract_splice_sites.py "$GTF" > splicesites.txt
hisat2_extract_exons.py        "$GTF" > exons.txt

# ====== 2) Build the HISAT2 genome index ======
hisat2-build --ss splicesites.txt --exon exons.txt "$GENOME_FA" "$INDEX_PREFIX"

# ====== 3) Align the 6 samples (paired-end) ======
# Samples: SRR27104543 SRR27104544 SRR27104545 SRR27104546 SRR27104547 SRR27104548
for SRR in SRR27104543 SRR27104544 SRR27104545 SRR27104546 SRR27104547 SRR27104548
do
  R1="${READS_DIR}/${SRR}_1.fastq.gz"
  R2="${READS_DIR}/${SRR}_2.fastq.gz"

  # Align -> SAM + summary
  if [ -n "$STRAND" ]; then
    hisat2 -p "$THREADS" --dta --rna-strandness "$STRAND" \
      -x "$INDEX_PREFIX" -1 "$R1" -2 "$R2" \
      -S "${SRR}.sam" --summary-file "${SRR}.hisat2_summary.txt"
  else
    hisat2 -p "$THREADS" --dta \
      -x "$INDEX_PREFIX" -1 "$R1" -2 "$R2" \
      -S "${SRR}.sam" --summary-file "${SRR}.hisat2_summary.txt"
  fi

  # Convert SAM -> sorted BAM and index
  samtools view -bS "${SRR}.sam" > "${SRR}.bam"
  samtools sort "${SRR}.bam" -o "${SRR}.sorted.bam"
  samtools index "${SRR}.sorted.bam"

  # (optional) remove large intermediates
  rm -f "${SRR}.sam" "${SRR}.bam"
done

echo "Done. Created:"
echo "  Index: ${INDEX_PREFIX}.[1-8].ht2"
echo "  For each SRR: *.hisat2_summary.txt, *.sorted.bam, *.sorted.bam.bai"
