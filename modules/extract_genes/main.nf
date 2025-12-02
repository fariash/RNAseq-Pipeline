#!/usr/bin/env nextflow

process EXTRACT_GENES {
    label 'process_low'
    container 'ghcr.io/bf528/pandas:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    path gtf

    output:
    path "gene_map.txt", emit: gene_map

    script:
    """
    gtf_to_genes.py -i $gtf -o gene_map.txt
    """
}
