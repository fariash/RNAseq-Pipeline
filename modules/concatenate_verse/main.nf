#!/usr/bin/env nextflow

process CONCATENATE_VERSE {
    label 'process_low'
    container 'ghcr.io/bf528/pandas:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    path exon_files
    path concatenate_verse


    output:
    path "counts_matrix.tsv", emit: matrix

    script:
    """
    ./concatenate_verse.py -i ${exon_files.join(" ")} -o counts_matrix.tsv
    """
}
