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
    
    def processBamFiles = { sample_id, sample_data, suffix ->
    def bam = file("${sample_data.path}/${sample_id}${suffix}.bam")
    def bai = file("${sample_data.path}/${sample_id}${suffix}.bam.bai")
    if (!bam.exists() || !bai.exists()) {
        error "BAM or BAI file not found for sample ${sample_id}"
    }
    return [sample_id, sample_data, bam, bai]
    }

    bams_all = SamplesWithReferences
    .branch {
        simplex: it[1].type == 'bam_simplex'
        merged: it[1].type == 'bam_merged'
    }

    bams_simplex = bams_all.simplex
    .map { sample_id, sample_data -> 
        processBamFiles(sample_id, sample_data, '.sorted')
    }

    bams_merged = bams_all.merged
    .map { sample_id, sample_data -> 
        processBamFiles(sample_id, sample_data, '.merged.sorted')
    }

    bams_combined = bams_simplex.mix(bams_merged)
    BAMs = bams_combined//.view()
    .filter { it[0] == 'BRNO1837' }
    // .view()
    ascat = RUN_ASCAT(BAMs)

    emit:
    ascat
    
}