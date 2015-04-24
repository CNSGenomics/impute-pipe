#!/bin/bash

#$ -N strand-qc
#$ -cwd
#$ -o job_reports/
#$ -e job_reports/
#$ -l h_vmem=8G

#-------------------------------------------------------------------------------
# Perform quality control processes to verify correct alignment of target data
# against reference data. Requires `refdatadir` to contain binary PLINK files.
#
# Outputs textual strand information and plots to `qcdatadir`.
#-------------------------------------------------------------------------------
source parameters.sh
wd=`pwd`"/"
flipfile="flip_SNPs.txt"

mkdir -p "${qcdatadir}plots"
for chr in {1..22}; do
  # TODO: check encoding of alleles (1234 -> ACGT)
  outdir="${qcdatadir}chr${chr}/"
  mkdir ${outdir}
  # create reference frequencies
  ${gcta} --bfile ${refdatadir}${refstem}${chr} --freq --out ${outdir}${refstem}${chr}
  # ignore SNPs that are not common between reference and target
  ${gcta_ref} --bfile ${rawdata} \
    --update-ref-allele "${outdir}${refstem}${chr}.freq" \
    --out "${outdir}${targetstem}_update" \
    --freq | grep -v Ignore
  # TODO: pipe grep output into a .txt, and repeat call excluding SNPs

  if [ $chr = 22 ]; then
    Rscript "${wd}exe/qc/CheckStrand.r" \
      "${outdir}${refstem}${chr}.freq" \
      "${outdir}${targetstem}_update.freq" \
      "${qcdatadir}plots/${targetstem}_${chr}.pdf" \
      "reference" \
      "target"
  fi

  # flip alleles according to strand file
  cat ${strand_file} | awk '{if ($5=="-") print $0}' | cut -f 1 > ${outdir}${flipfile}
  ${plink} --bfile ${rawdata} \
    --flip ${outdir}${flipfile} \
    --out "${outdir}${targetstem}_flip" \
    --allow-no-sex --make-bed --noweb
  # update reference allele to match datasets
  ${gcta_ref} --bfile "${outdir}${targetstem}_flip" \
    --update-ref-allele "${outdir}${refstem}${chr}.freq" \
    --out "${outdir}${targetstem}_update_flip" \
    --freq | grep -v Ignore

  if [ $chr = 22 ]; then
    # plot flipped alleles against reference
    Rscript "${wd}exe/qc/CheckStrand.r" \
      "${outdir}${refstem}${chr}.freq" \
      "${outdir}${targetstem}_update_flip.freq" \
      "${qcdatadir}plots/${targetstem}_${chr}_flip.pdf" \
      "reference" \
      "target (flipped)"
    # plot flipped against unflipped alleles
    Rscript "${wd}exe/qc/CheckStrand.r" \
      "${outdir}${targetstem}_update.freq" \
      "${outdir}${targetstem}_update_flip.freq" \
      "${qcdatadir}plots/${targetstem}_${chr}_target_flip.pdf" \
      "target" \
      "target (flipped)"
  fi

  # write QC stats to file
  Rscript "${wd}exe/qc/GetAlleleFreq.r" \
    "${outdir}${targetstem}_update.freq" \
    "${outdir}${targetstem}_update_flip.freq" \
    "${outdir}${refstem}${chr}.freq" \
    "${rawdata}.bim" \
    ${strand_file} \
    ${wd} \
    "FALSE"
done
