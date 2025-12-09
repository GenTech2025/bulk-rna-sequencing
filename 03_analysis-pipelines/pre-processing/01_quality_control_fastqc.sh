# run fastqc on all fastq paired end samples using 6 threads
fastqc ../02_data/*_1.fastq.gz ../02_data/*_2.fastq.gz \
       -o ../04_results/fastqc_output \
       -t 6

# run multiqc
multiqc ../04_results/fastqc_output/*.zip \
       -n "raw_fastq_files_QC" \
       -o ../04_results/multiqc_results
