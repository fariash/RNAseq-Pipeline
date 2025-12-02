#!/usr/bin/env nextflow
include { FASTQC } from './modules/fastqc/main.nf'
include { EXTRACT_GENES } from './modules/extract_genes/main.nf'
include { STAR } from './modules/star/main.nf'
include { STAR_ALIGN } from './modules/star_align/main.nf'
include { MULTIQC } from './modules/multiqc/main.nf'
include { VERSE } from './modules/verse/main.nf'
include { CONCATENATE_VERSE } from './modules/concatenate_verse/main.nf'



workflow {
    align_ch = Channel.fromFilePairs(params.reads)

    fastqc_channel = align_ch
        .flatMap { sample_id, reads -> reads.collect { read -> tuple(sample_id, read) } }

    fastqc_results = FASTQC(fastqc_channel)
    gtf_results    = EXTRACT_GENES(params.gtf)
    star_results   = STAR(params.genome, params.gtf)

    align_results  = STAR_ALIGN(align_ch, star_results)

    verse_results  = VERSE(align_results.bam, params.gtf)
    concat_input = concat_input = verse_results.counts.map{ id, file -> file }.collect()
    concat_matrix = CONCATENATE_VERSE(concat_input, file('bin/concatenate_verse.py'))


    multiqc_ch = fastqc_results.zip.map { id, zipfile -> zipfile }
                .mix(align_results.log.map { id, logfile -> logfile })
                .flatten()
                .collect()
            
    MULTIQC(multiqc_ch)
}







