process CELLBENDER_REMOVEBACKGROUND {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/cellbender:0.3.0--c4addb97ab2d83fe':
        'community.wave.seqera.io/library/cellbender:0.3.0--41318a055fc3aacb' }"

    input:
    tuple val(meta), path(h5ad)

    output:
    tuple val(meta), path("${prefix}.h5")               , emit: h5
    tuple val(meta), path("${prefix}_cell_barcodes.csv"), emit: barcodes
    tuple val(meta), path("${prefix}_metrics.csv")      , emit: metrics
    path "versions.yml"                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: "${meta.id}"
    args = task.ext.args ?: ""
    """
    TMPDIR=. cellbender remove-background \
        ${args} \
        --input ${h5ad} \
        --low-count-threshold 2 \
        --output ${prefix}.h5

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cellbender: \$(cellbender --version)
    END_VERSIONS
    """
}
