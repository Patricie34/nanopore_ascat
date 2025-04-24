include { RUN_ASCAT } from './modules.nf' // Import the RUN_ASCAT process

workflow ASCAT {
    take:
    Runlist
    References
    
    main:
    Runlist = channel.fromList(params.samplesheet)
	References = channel.fromList(params.ref_specific)
    
    SamplesReformated = Runlist.map {[it.name, it.reference, it]}
	ReferencesReformated = References.map {[it, it.refname]}

	SamplesWithReferences = SamplesReformated.combine(ReferencesReformated,by:1) //match parameters to individual samples
		.map({ sample -> [sample[1],sample[2]+(sample[3]) ]})
		// .view()
	BAMcollectedSorted = SamplesWithReferences.map { row ->
    if (row[1].type == 'bam_ascat') {
        def mergedBam = file("${row[1].path}/${row[0]}.merged.sorted.bam", checkIfExists: true)
        def mergedBai = file("${row[1].path}/${row[0]}.merged.sorted.bam.bai", checkIfExists: true)

        def V10_bam = file("${row[1].path}/${row[0]}.sorted.bam", checkIfExists: true)
        def V10_bai = file("${row[1].path}/${row[0]}.sorted.bam.bai", checkIfExists: true)

        if (mergedBam.exists() && mergedBai.exists()) {
            return [row[0], row[1], mergedBam, mergedBai]
        } else if (V10_bam.exists() && V10_bai.exists()) {
            return [row[0], row[1], V10_bam, V10_bai]
        } else {
            log.warn "Missing BAM or BAI for sample: ${row[0]}"
            return null
        }
    }
    }.filter { it != null }

    BAMcollectedSorted.view()
    ascat = RUN_ASCAT(BAMcollectedSorted)

    emit:
    ascat
    
}