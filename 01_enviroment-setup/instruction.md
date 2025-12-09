### Download and Install Miniconda
```bash
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