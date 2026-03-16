#!/usr/bin/env nextflow

/*
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//     nf-core/moleculardynamics
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//     Github : https://github.com/nf-core/moleculardynamics
// ----------------------------------------------------------------------------------------
//
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//    RMSD ANALYSIS Process
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//     Description:
//     - This process calculates the Root Mean Square Deviation (RMSD) of a molecular dynamics trajectory.
//     - It uses GROMACS tools to perform the analysis and outputs the RMSD data and plot.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

process ANALYSIS_RMSD {
    label 'process_low'
  
    publishDir "${params.outdir}/analysis", mode: 'copy'
    
    input:
    tuple val(sample), path(md_gro), path(md_noPBC_xtc)
    
    output:
    tuple val(sample), path("rmsd.xvg"), emit: rmsd_xvg
    path "versions.yml", emit: versions

    script:
    """
    echo "Calculating RMSD for the protein along the trajectory"
    # Select group 3 (usually C-alpha atoms) for RMSD calculation over the protein (group 1)
    printf "3\n1\n" | ${params.gmx_cmd} rms -s ${md_gro} -f ${md_noPBC_xtc} -o rmsd.xvg -tu ns

    gmx_version="\$(${params.gmx_cmd} --version 2>/dev/null | sed -n 's/^GROMACS version:[[:space:]]*//p' | head -n 1 || true)"
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gromacs: "${gmx_version:-unknown}"
    END_VERSIONS

    echo "RMSD analysis completed!"
    """
}