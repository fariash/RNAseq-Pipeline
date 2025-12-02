#!/usr/bin/bash nextflow

process STAR {
    label 'process_high'
    container 'ghcr.io/bf528/star:latest'
    publishDir params.outdir, mode: "copy"

    input:
    path genome 
    path gtf

    output:
    path "star_index", emit: index

    script:
    """
    mkdir -p star_index
    STAR --runThreadN ${task.cpus} \
         --runMode genomeGenerate \
         --genomeDir star_index \
         --genomeFastaFiles $genome \
         --sjdbGTFfile $gtf
    """
}
