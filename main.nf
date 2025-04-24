include { RUN_ASCAT } from './modules.nf' // Import the RUN_ASCAT process

workflow { 
    Runlist = channel.fromList(params.samplesheet)
	References = channel.fromList(params.ref_specific)
    
    SamplesReformated = Runlist.map {[it.name, it.reference, it]}
	ReferencesReformated = References.map {[it, it.refname]}

	SamplesWithReferences = SamplesReformated.combine(ReferencesReformated,by:1) //match parameters to individual samples
		.map({ sample -> [sample[1],sample[2]+(sample[3]) ]})
		// .view()
	BAMcollectedSorted = SamplesWithReferences.map { row ->
    def sampleId = row[0]
    def path = row[1].path

    if (row[1].type == 'bam_merged') {
        def bam = file("${path}/${sampleId}.merged.sorted.bam")
        def bai = file("${path}/${sampleId}.merged.sorted.bam.bai")
        if (bam.exists() && bai.exists()) {
            return [sampleId, row[1], bam, bai]
        } else {
            log.warn "Missing merged BAM/BAI for sample: ${sampleId}"
            return null
        }
    } else if (row[1].type == 'bam_V10') {
        def bam = file("${path}/${sampleId}.sorted.bam")
        def bai = file("${path}/${sampleId}.sorted.bam.bai")
        if (bam.exists() && bai.exists()) {
            return [sampleId, row[1], bam, bai]
        } else {
            log.warn "Missing V10 BAM/BAI for sample: ${sampleId}"
            return null
        }
    } else {
        return null
    }
}.filter { it != null }



    BAMcollectedSorted
    // .view()
    ascat = RUN_ASCAT(BAMcollectedSorted)

    //ascat = RUN_ASCAT(BAMcollectedSorted)   
}