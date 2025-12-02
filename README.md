# Bulk RNAseq Pipeline

### **Introduction**

Type 1 diabetes (T1D) is an autoimmune disease characterized by the
destruction of pancreatic β-cells, which are responsible for insulin
production and blood glucose regulation. Recent genetic studies have
identified TYK2, a Janus kinase involved in type I interferon (IFN-I)
signaling, as a susceptibility gene for T1D, suggesting that it may
influence both β-cell development and immune responses (Chandra et al., 2022). 
This study was performed to investigate how TYK2 affects β-cell differentiation,
maturation, and vulnerability to immune attack. To achieve this, the
authors used a combination of stem-cell differentiation models, RNA
sequencing, and bioinformatic analyses to examine gene expression
changes associated with TYK2 loss or inhibition. These computational
approaches allowed the researchers to uncover global transcriptional
programs, identify affected pathways such as KRAS signaling and antigen
presentation, and integrate molecular findings with functional assays to
reveal TYK2’s dual role in regulating β-cell identity and immune
protection.

### **Methods**

#### **RNA-seq Data Processing**

Paired-end FASTQ files for all samples were processed through a Nextflow
(25.04.6) [1] pipeline executed on the Boston University Shared
Computing Cluster. Quality control was performed using **FastQC
(v0.12.1)** [2] to assess per-base quality, adapter content, and GC
distribution under default parameters. **MultiQC (v1.25)** [3] was run once across all FastQC and STAR log outputs to aggregate quality metrics into a single report.

#### **Reference Preparation**

The **GRCh38 (primary assembly)** genome and the corresponding **GENCODE
v45 annotation (GTF)** were used to build a **STAR (v2.7.11b)** [4] genome index with default parameters and the flag `--runThreadN ${task.cpus}`. The GTF was
parsed with a custom Python (3.13.7) [5] script run in the **Pandas
(v2.3.3)** [6] container to produce a tab-delimited mapping of Ensembl
gene IDs to gene symbols.

#### **Alignment and Quantification**

Reads were aligned to the reference genome GRCh38 using **STAR_ALIGN
(v2.7.11b)** [4] with default parameters and the options
`--readFilesCommand zcat`, `--outSAMtype BAM Unsorted`, and
`--runThreadN ${task.cpus}`. The `--genomeDir` flag specified the precomputed STAR index, and the `--outFileNamePrefix` parameter appended sample identifiers to all output files. Log outputs (`*.Log.final.out`) were retained for
post-alignment QC. Gene-level counts were generated with **VERSE
(v0.1.5)** [7] using the `-S` flag. Per-sample count tables were
concatenated into a single matrix using a custom Python script within (pandas
v2.3.3) container.

#### **Differential Expression Analysis**

All downstream analysis was conducted in **R (v4.4.3)**[8] with **DESeq2
(v1.46.0)** [9]. Raw counts were imported as a
`DESeqDataSet.` Low-expression genes were filtered out by requiring ≥10
raw counts in at least 3 samples. Genes not meeting this criterion were
removed prior to DE analysis, and normalized with the default
median-ratio method. Differential expression between control and experimental conditions was tested using the Wald test. Genes with adjusted p \< 0.05 and \|log₂FoldChange\| \> 1 were considered significantly up- or down-regulated.

#### **Functional Enrichment**

Significant genes were analyzed with **Enrichr** [10] to identify
enriched biological pathways. In addition, **FGSEA (v1.32.4)** [11] was
applied on the full ranked list (ranked by Wald statistic) using the **MSigDB C2.CP v2025.1 Hs** [12] gene sets with parameters
`minSize = 15`, `maxSize = 500`, and default permutations. Pathways were ranked by adjusted p-value to highlight the most significantly enriched terms.

#### **Normalization and Visualization**

Variance-stabilizing transformation (**vst**) was applied to normalized
counts (`blind = FALSE`) to reduce heteroscedasticity. Principal
component analysis (PCA) was performed using
`plotPCA(vsd, intgroup = "condition")`. Sample-to-sample Euclidean
distances were visualized as a clustered heatmap via **pheatmap
(v1.0.12)** [13].

### **Quality Control Evaluation**

Across all six RNA-seq samples, total read counts ranged from \~84 M to
\~119 M reads per sample. Per-base sequence quality scores remained
consistently high (median Phred \> 30), and read length was 151 bp.
FASTQC flagged no major issues aside from minimal adapter content (≤
0.02 %), and duplication levels were modest (9–18 %). STAR alignment
showed \~97–98 % total mapped reads, with 93–94 % uniquely aligned, and
mismatch/indel rates \< 0.5 %. Collectively, these metrics indicate that
the sequencing and alignment were of high quality, with the data
suitable for reliable downstream differential expression analysis.

### **Discussion**

In Nature Communications, Chandra et al. (2022) characterized the transcriptional consequences of TYK2 knockout (KO) during pancreatic differentiation. Using bulk RNA-seq at the endocrine progenitor stage (S5), they identified 319 upregulated and 412 downregulated genes (FDR < 0.01). Reactome enrichment revealed suppression of β-cell development and β-cell gene-expression pathways (NEUROD1, PAX4, INSM1, ONECUT1) alongside activation of receptor tyrosine kinase (RTK) and extracellular matrix (ECM) signaling (KRAS, SPP1, COL2A1). These findings suggested that TYK2 loss impairs endocrine commitment while promoting proliferative and structural remodeling programs.

Applying equivalent criteria (padj < 0.05, |log₂ fold change| > 1) to the present dataset yielded a smaller number of significant genes (on the order of 150–200 total), reflecting differences in read depth and filtering thresholds but demonstrating the same directional pattern of regulation. The volcano plot showed distinct sets of up and downregulated genes, with the strongest effects corresponding to chromatin and signaling related loci (e.g., PCDHGA10, SLC2A14, ENSG00000289575, RPS4Y1).

Functional enrichment analyses were consistent with those reported by Chandra et al. Upregulated genes were enriched for chromatin modifying and proliferative transcription factors such as SUZ12, EED, PHC1, and REST, as well as TF perturbation signatures for Fli1, MYCN, and POU1F1, indicating activation of programs linked to progenitor maintenance and structural signaling. Downregulated genes included NEUROD1, HAND2, and PAX2, reflecting suppression of endocrine and neuronal differentiation processes analogous to those observed in TYK2-KO cells.

FGSEA using the MSigDB C2.CP collection—which integrates Reactome, WikiPathways, KEGG, and BioCarta identified highly significant pathways (padj < 0.01) including REACTOME_NEURONAL_SYSTEM, WP_CELL_LINEAGE_MAP_FOR_NEURONAL_DIFFERENTIATION, PID_P53_DOWNSTREAM_PATHWAY, PID_INTEGRIN1_PATHWAY, and REACTOME_EXTRACELLULAR_MATRIX_ORGANIZATION. Negative enrichment of neuronal and β-cell pathways indicated repressed differentiation, while positive enrichment of ECM and signaling-associated pathways reflected enhanced structural and stress-response activity. The presence of additional pathways such as WP_ADHD_AND_AUTISM_ASD_PATHWAYS likely arose from the broader multi-database gene-set coverage in MSigDB, whereas Chandra et al. limited enrichment to Reactome via g:Profiler.

Together, these results demonstrate strong concordance between the two analyses: TYK2 perturbation reprograms transcriptional networks away from endocrine differentiation toward ECM remodeling, stress response, and proliferative signaling, consistent with RTK-driven modulation of pancreatic progenitor fate rather than opposing biological trends.


### **References**

[1] Nextflow v25.04.6. Available at: <https://www.nextflow.io/>

[2] FastQC v0.12.1. Available at:
<https://www.bioinformatics.babraham.ac.uk/projects/fastqc/>

[3] MultiQC v1.25. Available at: <https://github.com/MultiQC/MultiQC>

[4] STAR v2.7.11b. Available at: <https://github.com/alexdobin/STAR>

[5] Python v3.13.7. Available at:
<https://www.python.org/downloads/release/python-3137/>

[6] Pandas v2.3.3. Available at: <https://pypi.org/project/pandas/>

[7] Verse v0.1.5. Available at:
<https://kim.bio.upenn.edu/software/verse.shtml>

[8] R v4.4.3. Available at: <https://www.r-project.org/>

[9] DESeq2 v1.46.0. Available at:
<https://bioconductor.org/packages/release/bioc/html/DESeq2.html>

[10] Enrichr Available at: <https://maayanlab.cloud/Enrichr/>

[11] FGSEA v1.32.4. Available at:
<https://bioconductor.org/packages/release/bioc/html/fgsea.html>

[12] MSigDB C2.CP v2025.1 Hs. Available at:
<https://www.gsea-msigdb.org/gsea/msigdb/collections.jsp>

[13] Pheatmap v1.0.12. Available at:
<https://cran.r-project.org/web/packages/pheatmap/index.html>
