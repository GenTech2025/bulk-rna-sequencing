# run fastqc on all fastq paired end samples using 6 threads
fastqc ../data/*_1.fastq.gz ../data/*_2.fastq.gz \
       -o fastqc_output \
       -t 6

# run multiqc
multiqc ../data/fastqc_output/*.zip \
       -n "raw_fastq_files_QC" \
       -o ../results/multiqc_results
