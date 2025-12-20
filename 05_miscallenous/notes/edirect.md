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

```