# Run the Nextflow process using kuberun
/storage1/shared_resources/nf/build/releases/nextflow-24.04.4-all kuberun xsvato01/nanopore_k8s/main.nf -r main -head-image 'cerit.io/nextflow/nextflow:24.04.4' \
-resume -with-report -params-file samplesheet.json -c my_local_nextflow.config
