# Scope of the project
The main aim of this project is to get a hands on overview of analyzing bulk-RNA sequencing data and get familiar with the tools and methods involved in each step of the analysis pipeline.

&emsp;&emsp;Initially, the plan was to create the pipeline from scratch i.e. starting from raw FASTQ files to downstream analysis (Functional Enrichment/GSEA). However, due to hardware limitations some of the steps such as **creating the indexed genome** have been skipped and in place of that pre-indexed genome has been downloaded from the following [webpage](https://benlangmead.github.io/aws-indexes/hisat).

## Stages of the project
This RNA sequencing data analysis project is classified into two main stages: a) Upstream Analysis and b) Downstream Analysis. Each of the stages have been described in brief below along with the different steps in each stage.

### a) Upstream Analysis
In this stage we will download and preprocess the raw FASTQ files and the output of this pipeline will be a counts matrix containg the gene expression values for each sample, additionally if metadata is not available for the dataset then a small pipeline will be created to create a metadata file using REST APIs.

&emsp;**Different steps involved in this stage is shown below:**
- Download raw FASTQ files from ENA using *wget*.
- Perform initial Quality Control of the raw reads using *FASTQC* and aggregate the results using *MultiQC*.
- Trim the reads using *trimmomatic* if required.
- Download pre-built reference genome from this [website](https://benlangmead.github.io/aws-indexes/hisat).
- Align the raw reads to the reference genome using *HISAT2*.
- Check the quality of alignment using *samtools*.
- Quantify the aligned reads using *featurecounts* from the *subread* package.

### b) Downstream Analysis
*To be Completed*
