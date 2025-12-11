### Download and Install Miniconda
```bash
#!/bin/bash

# Download miniconda installer to your home directory
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh

# Install miniconda and verify
bash ~/miniconda.sh
source ~/.bashrc
conda --version
```

### Create Conda enviroments using YAML files
```bash
# Create conda envrioment for upstream RNA seq analysis
conda create env --file=./conda/enviroment_upstream.yaml
```

##### Content of the enviroment_upstream.yaml
```yaml
name: rnaseq_upstream
channels:
  - conda-forge
  - bioconda
  - defaults

dependencies:
  # --- Core Python ---
  - python=3.12
  - pandas
  - numpy
  - scipy
  - jupyterlab

  # --- Metadata & API fetching ---
  - requests
  - httpx
  - pyyaml
  - xmltodict
  - beautifulsoup4

  # --- QC Tools ---
  - fastqc
  - multiqc
  - trimmomatic
  - fastp

  # --- Alignment & Quantification ---
  - hisat2
  - samtools
  - subread        # includes featureCounts

  # --- Downloaders / Accession Tools ---
  - sra-tools
  - enabrowsertools
  - aspera-cli

  # --- Miscallenous ---
  - pigz             # parallel gzip for fast decompression
  - seqkit           # fast FASTA/FASTQ manipulation
  - parallel         # for batch processing
  - pip

```