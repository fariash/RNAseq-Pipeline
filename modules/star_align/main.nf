#!/usr/bin/env nextflow

process STAR_ALIGN {
    label 'process_high'
    container 'ghcr.io/bf528/star:latest'
    publishDir params.outdir, mode: "copy"

    input:
    tuple val(name), path(reads)  
    path index                     

    output:
    tuple val(name), path("${name}.Aligned.out.bam"), emit: bam
    tuple val(name), path("${name}.Log.final.out"), emit: log

    script:
    """
    STAR --runThreadN ${task.cpus} \
         --genomeDir $index \
         --readFilesIn ${reads.join(" ")} \
         --readFilesCommand zcat \
         --outFileNamePrefix ${name}. \
         --outSAMtype BAM Unsorted \
         2> ${name}.Log.final.out
    """
}
