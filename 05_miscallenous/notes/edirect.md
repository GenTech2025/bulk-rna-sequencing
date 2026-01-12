# Notes for understanding how to use the NCBI Entrez Direct Utility


### List of Bash Commands to get Started

```bash
#!/bin/bash

# Check all available fields avaialble to retrieve
efetch -db biosample -id SAMN13939946 -format xml | xtract -outline

# Access specific fields from the xml response
cat "list_of_accessions.txt" | \
efetch -db biosample -format docsum | \
xtract -pattern DocumentSummary -element Accession Title Organism

# Project will continue on January 2026
```


#### Tasks to Complete
- Complete the metadata creation pipeline
- Extract the names of the samples with very poor quality mapping (less than 40%) and remove them from the final gene expression matrix.
- Start with downstream analysis script and mainly focus on Differential Gene Expression analysis with the goal to reproduce the results from the original paper.