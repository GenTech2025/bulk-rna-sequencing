# (2025) Sox9 inhibits Activin A to promote biliary maturation and branching morphogenesis

## Genomic Datasets in the Study
In total there were four transcriptomics dataset used in this study out of which two were generated in this study and two were previously published. Out of the four two datasets were of bulk-rna sequencing and two datasets were of single-cell RNA sequencing.

- Bulk-RNA Sequencing of Biliary Epithelial Cells (BECs) from adult control mice (3 samples) and Sox9 knockout (sox9ko) mice. **GEO: GSE249385**, **ENA: PRJNA1048936** (generated in this study)
- Bulk-RNA Sequencing of Biliary Epithelial Cells (BECs) from mice whith four levels of Sox9EGFP expression (negative,sublow,low,high). **GEO: GSE151387**, **ENA: PRJNA635658** (previously published)
- Single-Cell RNA Sequencing of EpCAM positive BECs. **GEO: GSE249558, ENA: PRJNA1049483** (generated in this study)
- Single-Cell RNA Sequencing of hepatoblasts, cholangiocytes(embryonic BECs) and hepatocytes. **GEO: GSE142089, ENA: PRJNA595892**. (previously published, only BECs were used in the present study)


## Practical Implementation

### Download raw FASTQ files from ENA/SRA
Downloaded from ENA using shell script provided by the ENA webpage.
The reads are paired end reads.

### Quality control using FASTQC

FastQC v0.12.1 used for quality control.

```bash
fastqc *_1.fastq.gz *_2.fastq.gz -o fastqc_output -t 6
```

Interpretation Guide: https://rtsf.natsci.msu.edu/genomics/technical-documents/fastqc-tutorial-and-faq.aspx

