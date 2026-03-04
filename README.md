# Bulk RNA-Sequencing Analysis Pipeline

End-to-end pipeline for analyzing bulk RNA-seq data, from raw FASTQ files to a gene expression count matrix, with downstream differential expression analysis.

---

## Table of Contents

1. [Study Overview](#study-overview)
2. [Dataset](#dataset)
3. [Project Structure](#project-structure)
4. [Environment Setup](#environment-setup)
5. [Upstream Analysis Pipeline](#upstream-analysis-pipeline)
   - [Step 0a: Download Raw FASTQ Files](#step-0a-download-raw-fastq-files)
   - [Step 0b: Download Genome Annotation Files](#step-0b-download-genome-annotation-files)
   - [Step 1: Quality Control](#step-1-quality-control)
   - [Step 2: Read Trimming](#step-2-read-trimming)
   - [Step 3: Genome Index Download](#step-3-genome-index-download)
   - [Step 4: Read Alignment](#step-4-read-alignment)
   - [Step 5: Post-Alignment QC](#step-5-post-alignment-qc)
   - [Step 6: Read Quantification](#step-6-read-quantification)
   - [Step 7: Gene Expression Matrix Generation](#step-7-gene-expression-matrix-generation)
   - [Step 8: Metadata Creation](#step-8-metadata-creation)

---

## Study Overview

This project re-analyses a published dataset investigating **genome-wide gene expression changes in skin tissue** from type 2 diabetes (T2D) patients versus non-diabetic controls, with the goal of understanding the molecular mechanisms underlying chronic wound formation.

The original study used DESeq2 to identify 184 differentially expressed genes (64 upregulated, 120 downregulated) and revealed significant disruptions in epigenetic regulation, growth factor signaling, and cell adhesion pathways.

- **Publication:** [Mutations et al., PMID 32084158](https://pubmed.ncbi.nlm.nih.gov/32084158/)
- **Sequencing platform:** Illumina HiSeq 4000
- **Library type:** Single-end, 50 bp reads

The primary goal of this project is to get hands-on experience with the full bulk RNA-seq analysis workflow and become familiar with the tools used at each stage.

---

## Dataset

| Field | Details |
|---|---|
| BioProject | PRJNA603669 |
| Source | NCBI SRA / ENA |
| Samples | 27 human skin biopsy samples |
| Groups | 14 type 2 diabetes patients, 13 healthy controls |
| Read type | Single-end |
| Read length | 50 bp |
| Dataset size | ~11 GB |

---

## Project Structure

```
bulk-rna-sequencing/
├── 00_documentation/
│   ├── 01_project-documentation.md   # Project goals and background
│   └── 02_methods.md                 # Detailed methodology notes
├── 01_enviroment-setup/
│   ├── conda/
│   │   ├── enviroment_upstream.yaml  # Conda env for upstream analysis
│   │   └── enviroment_downstream.yaml
│   ├── docker/
│   │   ├── Dockerfile_eda
│   │   └── docker.md
│   └── instruction.md                # Environment setup instructions
├── 02_data/
│   ├── genome-alignment/             # Sorted BAM files (gitignored)
│   ├── genome-index/                 # HISAT2 pre-built index (gitignored)
│   │   └── grch38_snp_tran/
│   ├── genome_annotation_files/      # GTF + FASTA files (gitignored)
│   ├── trimmed-reads/                # fastp-trimmed FASTQ files
│   ├── intermediate-files/
│   │   └── available_fields.txt      # SRA metadata field names
│   └── processed-data/
│       ├── raw_counts.txt            # Raw featureCounts output
│       ├── raw_counts.txt.summary    # featureCounts summary
│       ├── counts.csv                # Cleaned gene expression matrix
│       └── metadata_run_sample_biosample.csv
├── 03_analysis-pipelines/
│   ├── upstream-analysis/
│   │   ├── 00_PRJNA603669_raw_fastq.sh       # Download raw FASTQs
│   │   ├── 00_Genome_Annotation.sh           # Download genome + GTF
│   │   ├── 01_quality_control_fastqc.sh      # FastQC + MultiQC
│   │   ├── 02_trimming.sh                    # fastp adapter trimming
│   │   ├── 03_genome_index.sh                # Download HISAT2 index
│   │   ├── 04_read_alignment.sh              # HISAT2 alignment
│   │   ├── 05_post_alignment_QC.sh           # samtools + MultiQC
│   │   ├── 06_read_quantification.sh         # featureCounts
│   │   ├── 07_post_qunatification_processing.ipynb  # Build count matrix
│   │   ├── 08_metadata_creation.ipynb        # Map SRR → BioSample
│   │   └── 08_metadata_creation.sh           # entrez-direct commands
│   └── downstream_analysis/
│       └── analysis.R                        # DESeq2 downstream analysis
├── 04_results/
│   ├── fastqc_output/                # Per-sample FastQC reports
│   ├── multiqc_results/              # Aggregated pre-trim QC report
│   └── post_alignment_QC/            # samtools stats + MultiQC report
├── 05_miscallenous/
│   ├── custom_scripts/
│   │   └── custom_wget.py            # Modified ENA download script
│   └── notes/
│       └── edirect.md
└── README.md
```

---

## Environment Setup

All upstream analysis tools are managed via Conda.

**1. Install Miniconda**

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh
source ~/.bashrc
conda --version
```

**2. Create the upstream analysis environment**

```bash
conda env create --file=01_enviroment-setup/conda/enviroment_upstream.yaml
conda activate rnaseq_upstream
```

The environment includes the following tools:

| Category | Tools |
|---|---|
| QC | FastQC, MultiQC, fastp, Trimmomatic |
| Alignment | HISAT2, SAMtools |
| Quantification | featureCounts (Subread) |
| Metadata | entrez-direct, sra-tools |
| Python | Python 3.12, pandas, numpy, JupyterLab |
| Utilities | pigz, seqkit, GNU parallel |

---

## Upstream Analysis Pipeline

### Step 0a: Download Raw FASTQ Files

Raw single-end FASTQ files for all 27 samples are downloaded from the ENA FTP server. The download script was adapted from the ENA-generated shell script using `05_miscallenous/custom_scripts/custom_wget.py` to redirect output into the correct project directory.

```bash
bash 03_analysis-pipelines/upstream-analysis/00_PRJNA603669_raw_fastq.sh
```

Output: `02_data/*.fastq.gz` (27 files, ~11 GB)

---

### Step 0b: Download Genome Annotation Files

The reference genome FASTA and gene annotation GTF are downloaded from Ensembl (GRCh38, release 115). These files are needed later for read quantification.

The GRCh38 genome uses numerical chromosome notation (1, 2, …, 22, X, Y), which was confirmed by inspecting the BAM header:

```bash
samtools view -H SRR10983637.trim.sorted.bam | grep "^@SQ" | head -5
# @SQ  SN:1  LN:248956422
# @SQ  SN:10 LN:133797422
```

```bash
bash 03_analysis-pipelines/upstream-analysis/00_Genome_Annotation.sh
```

| File | Source |
|---|---|
| `Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa.gz` | Ensembl FTP, release 115 |
| `Homo_sapiens.GRCh38.115.gtf.gz` | Ensembl FTP, release 115 |

Output: `02_data/genome_annotation_files/`

---

### Step 1: Quality Control

Initial QC is performed on the raw FASTQ files using **FastQC**. Results are aggregated into a single interactive report using **MultiQC**.

```bash
bash 03_analysis-pipelines/upstream-analysis/01_quality_control_fastqc.sh
```

Key findings from QC:
- A large proportion of reads showed **adapter contamination**, requiring trimming before alignment.

Output:
- `04_results/fastqc_output/` — per-sample FastQC HTML + ZIP files
- `04_results/multiqc_results/raw_fastq_files_QC_single_end.html` — aggregated report

---

### Step 2: Read Trimming

Adapter sequences and low-quality bases are removed using **fastp**. Trimmomatic was evaluated but fastp was chosen for its better adapter auto-detection performance on this dataset.

```bash
bash 03_analysis-pipelines/upstream-analysis/02_trimming.sh
```

Parameters used:

| Parameter | Value | Description |
|---|---|---|
| `-q` | 20 | Trim low-quality 3′ bases below Q20 |
| `-l` | 20 | Discard reads shorter than 20 bp after trimming |
| `--trim_poly_x` | — | Remove poly-A/T/G/C tails |
| `--thread` | 8 | Parallel threads |

Output: `02_data/trimmed-reads/*.trim.fastq.gz`

---

### Step 3: Genome Index Download

Building a HISAT2 genome index from scratch requires significant RAM and time. To work around hardware limitations, a **pre-built HISAT2 index** is downloaded directly.

```bash
bash 03_analysis-pipelines/upstream-analysis/03_genome_index.sh
```

| Index | Source |
|---|---|
| `grch38_snptran` (GRCh38 + SNPs + transcripts) | [HISAT2 pre-built indexes](https://benlangmead.github.io/aws-indexes/hisat) |

Output: `02_data/genome-index/grch38_snp_tran/`

---

### Step 4: Read Alignment

Trimmed reads are aligned to the GRCh38 reference genome using **HISAT2**. The resulting SAM files are converted to sorted, indexed BAM files using **SAMtools**. SAM files are removed after conversion to save disk space.

```bash
bash 03_analysis-pipelines/upstream-analysis/04_read_alignment.sh
```

Key parameters:

| Parameter | Value | Description |
|---|---|---|
| `-p` | 8 | Threads |
| `--rna-strandness` | R | Reverse-stranded library |
| `-U` | `*.trim.fastq.gz` | Single-end input |

Pipeline per sample:
```
HISAT2 → SAM → BAM (samtools view) → Sorted BAM (samtools sort) → Index (samtools index)
```

Output: `02_data/genome-alignment/*.trim.sorted.bam`

> **Note:** Peak RAM usage during alignment did not exceed ~10 GB.

---

### Step 5: Post-Alignment QC

Alignment quality metrics are collected for each BAM file using **SAMtools** and summarised in an interactive **MultiQC** report.

```bash
bash 03_analysis-pipelines/upstream-analysis/05_post_alignment_QC.sh
```

Three SAMtools commands are run per sample:

| Command | Output | Description |
|---|---|---|
| `samtools flagstat` | `*.flagstat.txt` | Overall mapping statistics |
| `samtools stats` | `*.samtools_stats.txt` | Read length, coverage |
| `samtools idxstats` | `*.idxstats.txt` | Per-chromosome read distribution |

Output:
- `04_results/post_alignment_QC/` — per-sample metric files
- `04_results/post_alignment_QC/multiqc_alignment_report/multiqc_report.html`

> **Note:** Several samples showed very low mapping rates (1.7–40%). This is likely attributable to FFPE RNA library preparation, which is known to cause fragmentation and degradation artefacts. Samples below 40% mapping are flagged for exclusion from the final count matrix.

---

### Step 6: Read Quantification

Aligned reads are counted at the gene level using **featureCounts** from the Subread package. Only reads overlapping annotated exons are counted, and counts are summarised per `gene_id`.

```bash
bash 03_analysis-pipelines/upstream-analysis/06_read_quantification.sh
```

Key parameters:

| Parameter | Value | Description |
|---|---|---|
| `-T` | 4 | Threads |
| `-t` | exon | Feature type to count |
| `-g` | gene_id | Attribute for grouping features |
| `-a` | `Homo_sapiens.GRCh38.115.gtf` | Annotation file |

Output:
- `02_data/processed-data/raw_counts.txt` — raw count matrix (78,899 genes × 27 samples)
- `02_data/processed-data/raw_counts.txt.summary` — per-sample assignment summary

---

### Step 7: Gene Expression Matrix Generation

The raw featureCounts output is processed in a Jupyter notebook to produce a clean, analysis-ready count matrix.

**Notebook:** `03_analysis-pipelines/upstream-analysis/07_post_qunatification_processing.ipynb`

Steps performed:

1. **Load** `raw_counts.txt` (78,899 rows × 33 columns)
2. **Set index** to `Geneid` (Ensembl gene IDs)
3. **Drop annotation columns** (Chr, Start, End, Strand, Length), keeping only the 27 count columns
4. **Rename columns** from full BAM file paths to short SRR run accessions using regex:
   ```python
   counts.columns = counts.columns.str.extract(r"(SRR\d+)", expand=False)
   ```
5. **Export** the cleaned matrix to TSV:
   ```python
   counts.to_csv("../../02_data/processed-data/counts.csv", sep='\t', index=True)
   ```

Final output: `02_data/processed-data/counts.csv`

| Dimension | Value |
|---|---|
| Rows | 78,899 (Ensembl gene IDs) |
| Columns | 27 (SRR run accessions) |

---

### Step 8: Metadata Creation

A metadata file linking each SRR run accession to its BioSample ID and biological annotation is created using the **entrez-direct** (`esearch` / `efetch`) command-line tools.

**Notebook:** `03_analysis-pipelines/upstream-analysis/08_metadata_creation.ipynb`

```bash
# Inspect available SRA metadata fields
esearch -db sra -query PRJNA603669 \
  | efetch -format runinfo \
  | head -n 1 \
  > 02_data/intermediate-files/available_fields.txt

# Retrieve Run accession and SampleName
esearch -db sra -query PRJNA603669 \
  | efetch -format runinfo \
  | cut -d',' -f1,29,30
```

Output: `02_data/processed-data/metadata_run_sample_biosample.csv`
