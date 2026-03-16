#!/usr/bin/env nextflow

/*
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//     nf-core/moleculardynamics
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//     Github : https://github.com/nf-core/moleculardynamics
// ----------------------------------------------------------------------------------------
//
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//    POST-PROCESSING Process
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//     Description:
//     - This process handles the post-processing of molecular dynamics simulation results.
//     - It removes possible periodicity artifacts along the trajectory.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

process POST_PROCESSING {
    label 'process_low'
  
    publishDir "${params.outdir}/post_processing", mode: 'copy'
    
    input:
    tuple val(sample), path(md_tpr), path(md_xtc)
    
    output:
    tuple val(sample), path("md_noPBC.xtc"), emit: post_xtc
    path "versions.yml", emit: versions

    script:
    """
    echo "Starting post-processing to remove periodicity artifacts"
    echo "We center the protein and output the system"
    printf "1\n0\n" | ${params.gmx_cmd} trjconv -s ${md_tpr} -f ${md_xtc} -o md_noPBC.xtc -pbc mol -center

    gmx_version="\$(${params.gmx_cmd} --version 2>/dev/null | sed -n 's/^GROMACS version:[[:space:]]*//p' | head -n 1 || true)"
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gromacs: "${gmx_version:-unknown}"
    END_VERSIONS

    echo "Post-processing completed!"
    """
}