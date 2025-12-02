#!/usr/bin/bash nextflow

process MULTIQC {

    container 'ghcr.io/bf528/multiqc:latest'
    publishDir params.outdir, mode: "copy"

    input:
    path("*")

    output:
    path("multiqc_report.html")

    script:
    """
    multiqc -f . -o .
    """
}