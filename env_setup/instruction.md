# Download and Install Miniconda
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh
source ~/.bashrc
conda --version
```
# Install STAR, Trimmomatic, Samtools, FeatureCounts

```bash
# Create a new conda enviroment for our project
conda create -n bulk_rna_seq
# We can install STAR using conda
conda install -c bioconda star
```