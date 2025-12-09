# single-sample example
fastp \
  -i sample.fastq.gz \
  -o sample.trim.fastq.gz \
  -q 20 \          # trim low-quality tail below Q20
  -l 20 \          # discard reads shorter than 20bp after trimming
  --trim_poly_x \  # trim poly-A/poly-T/poly-G/X tails
  --detect_adapter_for_pe \ # harmless for SE; helps with adapter detection (fastp auto-detects anyway)
  --thread 8 \
  --html sample.fastp.html \
  --json sample.fastp.json
