# create the output directory
mkdir -p ../../04_results/fastqc_output ../../04_results/multiqc_results


# run fastqc on all single-end fastq samples using 6 threads
fastqc ../../02_data/*.fastq.gz \
       -o ../../04_results/fastqc_output \
       -t 8

# run multiqc
multiqc ../../04_results/fastqc_output/*.zip \
       -n "raw_fastq_files_QC_single_end" \
       -o ../../04_results/multiqc_results
