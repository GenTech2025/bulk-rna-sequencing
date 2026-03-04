# ============================================================
# Differential Gene Expression Analysis
# Study : Type 2 Diabetes vs Non-Diabetic Controls
#         BioProject: PRJNA603669  |  GEO: GSE144409
# Design: Skin biopsy bulk RNA-seq, 50bp single-end, Illumina HiSeq 4000
# Ref   : https://pubmed.ncbi.nlm.nih.gov/32084158/
# ============================================================
# NOTE: Set the working directory to the project root before running.
#       All file paths in this script are relative to that root.
# ============================================================


# ============================================================
# SECTION 1 — LOAD LIBRARIES
# ============================================================

# Load all required libraries upfront so that missing packages are caught
# immediately rather than mid-analysis.
#
# CRAN packages (installed in the Dockerfile via install.packages):
#   - tidyverse    : data manipulation (dplyr, tidyr, readr, stringr) and ggplot2
#   - pheatmap     : sample-to-sample correlation heatmap
#   - RColorBrewer : colour palettes for heatmaps and plots
#   - cowplot      : combining multiple ggplot objects into a single panel figure
#   - msigdbr      : programmatic access to MSigDB gene-set collections (used for GSEA)
#
# Bioconductor packages (installed via BiocManager::install):
#   - DESeq2         : core differential expression engine (normalisation, GLM, Wald test)
#   - apeglm         : empirical-Bayes log fold-change shrinkage (posterior estimation)
#   - ComplexHeatmap : publication-quality annotated heatmaps for top DEGs
#   - biomaRt        : query Ensembl to map Ensembl IDs → HGNC symbols + metadata
#   - org.Hs.eg.db   : human gene annotation database (used as background for GO ORA)
#   - clusterProfiler: Gene Ontology over-representation analysis (ORA)
#   - fgsea          : fast pre-ranked Gene Set Enrichment Analysis (GSEA)


# ============================================================
# SECTION 2 — LOAD RAW DATA
# ============================================================

# Load the gene expression count matrix.
#   - File  : 02_data/processed-data/counts.csv
#   - Format: tab-separated; rows = Ensembl gene IDs, columns = SRR run accessions
#   - The first column is unnamed in the file (it becomes "...1" in R);
#     promote it to row names so the matrix is purely numeric.
#   - Expected dimensions: ~78,899 genes × 27 samples before any filtering.

# Load the sample annotation / metadata file.
#   - File  : 02_data/processed-data/metadata_run_sample_biosample.csv
#   - Format: CSV with columns — Run (SRR accession), BioSample, SampleName (GSM accession)
#   - Sort the annotation by Run accession so its row order matches the column
#     order of the count matrix.

# Sanity-check that every column in the count matrix maps to a row in the
# annotation and that the order is identical. Halt with an informative message
# if there is a mismatch — do not allow the analysis to continue silently.


# ============================================================
# SECTION 3 — ASSIGN SAMPLE CONDITIONS
# ============================================================

# Derive the experimental condition (Control vs T2D) from the GSM accession
# stored in the SampleName column.
#
# GSE144409 sample layout (verified against NCBI GEO):
#   GSM4288318 – GSM4288330  →  13 non-diabetic controls    (SRR10983637 – SRR10983649)
#   GSM4288331 – GSM4288344  →  14 type-2 diabetes patients (SRR10983650 – SRR10983663)
#
# Extract the numeric part of each GSM accession.
# Assign "Control" where that number ≤ 4288330, "T2D" otherwise.
# Store condition as a factor with levels c("Control", "T2D") so that
# DESeq2 treats "Control" as the reference level in the design formula.
# Print a table of condition counts to verify the assignment.


# ============================================================
# SECTION 4 — SAMPLE QUALITY FILTERING
# ============================================================

# Load the alignment QC summary produced by MultiQC during upstream analysis.
#   - File: 04_results/post_alignment_QC/general_stats_table.csv
#   - Contains per-sample alignment statistics including "% Mapped".
#   - Note: the file has a UTF-8 BOM; readr handles this automatically.
#
# Identify samples with a mapping rate below 40 %.
# These samples are considered too poorly aligned to the reference genome
# to provide reliable gene expression estimates and must be excluded.
#
# Expected exclusions (9 samples total):
#   SRR10983637 ( 6.5%), SRR10983641 ( 3.5%), SRR10983644 (24.4%),
#   SRR10983645 ( 1.7%), SRR10983650 (14.8%), SRR10983652 (12.4%),
#   SRR10983653 ( 1.7%), SRR10983654 ( 6.6%), SRR10983655 (18.4%)
#
# Remove the low-quality columns from the count matrix and drop the
# corresponding rows from the annotation data frame.
# After filtering, ~18 samples should remain (approximately 9 control, 9 T2D).


# ============================================================
# SECTION 5 — CREATE OUTPUT DIRECTORY
# ============================================================

# All downstream output files (CSV tables, PDF plots) will be written to:
#   04_results/downstream_analysis/
#
# Create this directory if it does not already exist.
# Use recursive = TRUE so that any missing parent directories are also created.


# ============================================================
# SECTION 6 — DESeq2 DIFFERENTIAL EXPRESSION ANALYSIS
# ============================================================

# Step 6a — Build the integer count matrix
#   - Convert the raw_data data frame to a numeric matrix.
#   - Round any non-integer values (featureCounts may produce fractional counts
#     in some multi-overlap modes) and coerce storage mode to "integer".
#   - DESeq2 requires integer counts; it will error on non-integer input.

# Step 6b — Build the colData data frame
#   - The colData must have row names matching the column names of the count matrix.
#   - Include at minimum the "condition" factor used in the design formula.
#   - Use column_to_rownames("Run") on the annotation to achieve this alignment.

# Step 6c — Construct the DESeqDataSet object
#   - Use DESeqDataSetFromMatrix(countData, colData, design = ~ condition).
#   - The design ~ condition tells DESeq2 to model expression as a function
#     of the two-level condition factor (Control as reference, T2D as treatment).

# Step 6d — Pre-filter low-count genes
#   - Remove genes whose total read count across all samples is below 10.
#   - This is a minimal filter recommended by the DESeq2 vignette; it reduces
#     memory usage and speeds up fitting without discarding informative genes.
#   - Stricter filters (e.g. counts-per-million thresholds) are also reasonable.

# Step 6e — Run the DESeq2 pipeline
#   - DESeq() sequentially performs:
#       1. Size-factor estimation (median-of-ratios normalisation)
#       2. Dispersion estimation (gene-wise, then trended, then MAP shrinkage)
#       3. Negative binomial GLM fitting per gene
#       4. Wald significance test for the condition coefficient
#   - Print a summary of raw results (alpha = 0.05) to the console.

# Step 6f — Extract Wald-test results
#   - Call results(dds, contrast = c("condition", "T2D", "Control")) to get
#     the comparison of interest: positive LFC means higher expression in T2D.
#   - Use pAdjustMethod = "BH" (Benjamini-Hochberg) for multiple-testing correction.
#   - The results object contains: baseMean, log2FoldChange, lfcSE, stat, pvalue, padj.

# Step 6g — Apply apeglm LFC shrinkage
#   - Call lfcShrink(dds, coef = "condition_T2D_vs_Control", type = "apeglm").
#   - apeglm fits a Cauchy prior on the LFC and returns a posterior median.
#   - This shrinks noisy LFC estimates for low-count genes toward zero,
#     making MA plots and ranked gene lists more reliable.
#   - IMPORTANT: apeglm drops padj, pvalue, and stat from its result object;
#     those columns must be taken from the original Wald-test res (Step 6f).


# ============================================================
# SECTION 7 — COMBINE RESULTS & CLASSIFY DEGs
# ============================================================

# Merge the two result objects into a single data frame:
#   - From res        (Wald test) : baseMean, stat, pvalue, padj
#   - From res_shrunk (apeglm)    : log2FoldChange (shrunk), lfcSE (posterior SD)
#   - Promote row names to a column ("ensembl_gene_id") in both before joining.
#   - Left-join on ensembl_gene_id so every gene from the Wald test is retained.
#
# Sort rows by padj (most significant first).
#
# Add a "significance" column classifying each gene as:
#   "Up"   — padj < 0.05  AND  log2FoldChange >  1  (≥ 2-fold higher in T2D)
#   "Down" — padj < 0.05  AND  log2FoldChange < -1  (≥ 2-fold lower in T2D)
#   "NS"   — everything else (not significant or fold-change below threshold)
#
# Print counts of Up / Down / total significant genes to the console.
# The original study reported 184 DEGs (64 up, 120 down); expect comparable
# numbers given that some low-quality samples have been excluded here.


# ============================================================
# SECTION 8 — GENE ANNOTATION (biomaRt)
# ============================================================

# Connect to the Ensembl BioMart server and query the human gene dataset.
#   - useMart("ensembl", dataset = "hsapiens_gene_ensembl")
#   - Requires internet access from within the Docker container.
#
# For every Ensembl gene ID in res_df, retrieve:
#   - hgnc_symbol    : human gene symbol (e.g. "TP53")
#   - description    : plain-text gene description
#   - gene_biotype   : e.g. "protein_coding", "lncRNA", "pseudogene"
#   - chromosome_name: chromosome on which the gene is located
#
# Some Ensembl IDs map to multiple rows (retired/merged IDs);
# deduplicate by keeping only the first record per Ensembl ID.
#
# Left-join the annotation onto res_df so that all genes are retained
# even if biomaRt could not return a symbol (those rows will have NA).
#
# Select and reorder columns for the final output table:
#   ensembl_gene_id, hgnc_symbol, log2FoldChange, lfcSE, stat,
#   pvalue, padj, significance, description, gene_biotype, chromosome_name
#
# Save two CSV files:
#   DEG_results_all_annotated.csv  — all tested genes (full results table)
#   DEG_results_significant.csv    — significant DEGs only (Up + Down)


# ============================================================
# SECTION 9 — QUALITY CONTROL PLOTS
# ============================================================

# --- 9a. PCA Plot ---
# Perform variance-stabilising transformation (VST) on the DESeqDataSet.
#   - vst(dds, blind = TRUE): transformation is fitted independently of
#     condition labels, making it unbiased for QC purposes.
#
# Extract the top two principal components using DESeq2's plotPCA with
# returnData = TRUE to obtain a tidy data frame for manual ggplot styling.
#
# Plot PC1 vs PC2 with:
#   - Points coloured by condition (blue = Control, red = T2D)
#   - Axis labels showing the % variance explained by each PC
#   - Samples from the same condition should cluster together if biological
#     signal dominates over technical variation.
#
# Save as: PCA_plot.pdf

# --- 9b. Sample-to-sample Pearson correlation heatmap ---
# Compute pairwise Pearson correlations across all retained samples using
# the VST-normalised count matrix (genes as features).
#   - cor(vst_mat, method = "pearson") produces an n × n correlation matrix.
#   - Values near 1 indicate highly similar global transcriptomes.
#   - Samples within the same condition should show higher mutual correlation
#     than samples across conditions.
#
# Annotate rows and columns with a condition colour bar using pheatmap's
# annotation_col / annotation_row arguments.
# Use hierarchical clustering (Euclidean distance) on both axes.
#
# Save as: sample_correlation_heatmap.pdf


# ============================================================
# SECTION 10 — DGE VISUALISATION
# ============================================================

# --- 10a. MA Plot ---
# Plot mean expression (baseMean on log10 x-axis) vs shrunk LFC (y-axis).
#   - Colour points by significance class: Up = red, Down = blue, NS = grey.
#   - Add dashed horizontal reference lines at LFC = ±1 (fold-change threshold)
#     and a solid line at LFC = 0.
#   - With apeglm shrinkage, low-count genes with inflated LFC estimates are
#     pulled toward zero, resulting in a characteristic funnel shape.
#
# Save as: MA_plot.pdf

# --- 10b. Combined QC summary panel (cowplot) ---
# Use plot_grid() to assemble the PCA plot (panel A) and the MA plot (panel B)
# side by side in a single landscape figure.
#   - ncol = 2, label_size = 14
# This panel provides an at-a-glance summary of data quality and DE results.
#
# Save as: QC_summary_panel.pdf

# --- 10c. Volcano Plot ---
# Plot shrunk LFC (x-axis) against -log10(padj) (y-axis) for all tested genes.
#   - Colour points by significance class (Up / Down / NS).
#   - Cap the y-axis at 50 to prevent extreme p-values from distorting the scale.
#   - Add dashed vertical lines at LFC = ±1 and a dashed horizontal line at
#     -log10(0.05) to visually demarcate the significance region.
#   - Label the 20 most significant DEGs with their HGNC symbol using
#     geom_text (ggrepel is not available in this Docker image).
#
# Save as: volcano_plot.pdf


# ============================================================
# SECTION 11 — HEATMAP OF TOP 50 DEGs  (ComplexHeatmap)
# ============================================================

# Select the 50 genes with the smallest adjusted p-values from sig_degs.
#
# Extract their VST-normalised expression values from the vst_mat matrix.
#
# Z-score scale each gene across samples (subtract row mean, divide by row SD)
# so that expression patterns are visually comparable across genes that differ
# in absolute expression level.
#   - t(scale(t(matrix))) applies row-wise z-scoring.
#
# Create a HeatmapAnnotation bar along the top of the heatmap showing the
# condition for each sample column (blue = Control, red = T2D).
#
# Build the Heatmap with:
#   - Blue–white–red colour scale (RdBu palette, reversed so red = high)
#   - Hierarchical clustering of both rows (genes) and columns (samples)
#   - Row labels showing HGNC symbol; fall back to Ensembl ID if unavailable
#   - Column and row label font sizes set to 8 pt
#
# Draw the heatmap inside a pdf() device and close with dev.off().
# Save as: top50_DEGs_heatmap.pdf


# ============================================================
# SECTION 12 — FUNCTIONAL ENRICHMENT  (clusterProfiler — GO ORA)
# ============================================================

# Separate significant DEGs into upregulated and downregulated gene lists.
#   - Use HGNC symbols as identifiers (keyType = "SYMBOL").
#   - Exclude genes without a valid HGNC symbol.
#
# Define the background universe as all genes that were tested AND
# successfully mapped to a HGNC symbol. Using a proper universe (rather
# than all human genes) prevents artificial inflation of significance.
#
# Run GO Biological Process over-representation analysis separately for
# upregulated and downregulated sets using enrichGO():
#   - OrgDb         = org.Hs.eg.db
#   - keyType       = "SYMBOL"
#   - ont           = "BP"   (Biological Process ontology)
#   - pAdjustMethod = "BH"
#   - pvalueCutoff  = 0.05
#   - qvalueCutoff  = 0.2
#
# Skip ORA if a gene list contains fewer than 3 genes.
#
# For each non-empty result:
#   - Generate a dot plot of the top 20 enriched GO terms.
#     Each dot represents one GO term; size = gene ratio, colour = p.adjust.
#   - Save the plot as a PDF and the full result table as a CSV.
#
# Outputs:
#   GO_BP_upregulated.pdf / GO_BP_upregulated.csv
#   GO_BP_downregulated.pdf / GO_BP_downregulated.csv


# ============================================================
# SECTION 13 — GSEA  (fgsea + MSigDB Hallmark gene sets)
# ============================================================

# Build a pre-ranked gene list for GSEA using ALL tested genes (not just DEGs).
#   - Rank by the DESeq2 Wald test statistic (from the original res object).
#   - The statistic encodes both direction and magnitude of differential expression:
#       positive stat → higher expression in T2D
#       negative stat → lower expression in T2D
#   - Use HGNC symbols as names; deduplicate to keep one entry per symbol.
#
# Load MSigDB Hallmark gene sets (50 curated pathways representing well-defined
# biological states) using msigdbr:
#   - msigdbr(species = "Homo sapiens", category = "H")
#   - Convert to a named list of character vectors (pathway name → gene symbols)
#     as required by fgsea.
#
# Run fgsea() with:
#   - minSize    = 15     : discard gene sets with fewer than 15 genes in the ranked list
#   - maxSize    = 500    : discard very large gene sets to avoid spurious enrichment
#   - nPermSimple = 10000 : number of simple permutations for p-value estimation
#   - set.seed(42)        : fix random seed for reproducibility
#
# Tidy the output:
#   - Convert the leadingEdge list column to a comma-separated character string.
#   - Clean pathway names: strip "HALLMARK_" prefix, replace underscores with
#     spaces, convert to title case for readable axis labels.
#   - Save full results as: GSEA_hallmark_results.csv
#
# Plot pathways that reach the conventional GSEA significance threshold (padj < 0.25):
#   - Horizontal bar chart where bar length encodes NES (normalised enrichment score).
#   - Fill colour encodes FDR: darker = more significant.
#   - Positive NES → pathway enriched in T2D; negative NES → enriched in Control.
#   - Dynamically adjust plot height based on the number of significant pathways.
#
# Save as: GSEA_hallmark_barplot.pdf
