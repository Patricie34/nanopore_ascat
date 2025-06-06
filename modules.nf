process RUN_ASCAT {
    tag "Running ASCAT analysis for ${PTCLid}"
    publishDir  "${params.outDir2}/${PTCLid}", mode:'copy'
    container "patricie/allelecounter-image:v1.0.0"
    label "l_cpu"
    label "xl_mem"

    input:
    tuple val(PTCLid), val(sample), path(tumour_bam), path(tumour_bai)

    output:
    path "*"
    script:
    """
   Rscript ${params.ASCAT} \
        ${tumour_bam} \
        ${PTCLid} \
        ${sample.gender}     
    """
}
