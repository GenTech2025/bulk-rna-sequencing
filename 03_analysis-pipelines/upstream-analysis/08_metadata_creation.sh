#!/usr/bin/env bash
set -euo pipefail

BIOPROJECT="PRJNA603669"

# Output locations
OUT_DIR="../../02_data/processed-data"
OUT_FILE="${OUT_DIR}/metadata_run_sample_biosample.csv"

# Create directory if it doesnt already exist
mkdir -p "$OUT_DIR"

# Fetch runinfo and extract fields
esearch -db sra -query "$BIOPROJECT" \
| efetch -format runinfo \
| awk -F',' '
NR==1{
  for(i=1;i<=NF;i++){
    if($i=="Run") r=i
    if($i=="BioSample") b=i
    if($i=="SampleName") s=i
  }
  print "Run,BioSample,SampleName"
  next
}
{
  print $r "," $b "," $s
}
' > "$OUT_FILE"

echo "Metadata file written to: $OUT_FILE"
