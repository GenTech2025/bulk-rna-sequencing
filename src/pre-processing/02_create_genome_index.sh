# STAR manual: https://physiology.med.cornell.edu/faculty/skrabanek/lab/angsd/lecture_notes/STARmanual.pdf#page=4.41

# Download the musmusculus fasta and gtf file from ensembl
#wget https://ftp.ensembl.org/pub/release-115/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna_sm.primary_assembly.fa.gz \
     -P ../../data/preprocessing-data

#wget https://ftp.ensembl.org/pub/release-115/gtf/mus_musculus/Mus_musculus.GRCm39.115.gtf.gz \
     -P ../../data/preprocessing-data

# Unzip the .gz files
#gunzip ../../data/preprocessing-data/*.gz

# Create the genome index directory
#mkdir -p ../../data/preprocessing-data/reference

# Create the genome index using STAR
STAR --runThreadN 4 \
     --runMode genomeGenerate \
     --genomeDir ../../data/preprocessing-data/reference \
     --genomeFastaFiles ../../data/preprocessing-data/Mus_musculus.GRCm39.dna_sm.primary_assembly.fa \
     --sjdbGTFfile ../../data/preprocessing-data/Mus_musculus.GRCm39.115.gtf
     
# The making of genome index is taking too long