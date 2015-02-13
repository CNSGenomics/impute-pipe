#!/bin/sh

#$ -N strand-qc
#$ -cwd
#$ -o job_reports/
#$ -e job_reports/
#$ -l h_vmem=8G

wd=`pwd`"/"
ref_dir="/reference/data/path/"
trg_dir="${wd}data/target/"
ref_stem="reference_file_stem"
trg_stem=""
strand="${trg_dir}/strand/"
flip_file="flip_SNPs.txt"
plink="${wd}exe/plink"
gcta="${wd}exe/gcta64"
gcta_ref="${wd}exe/gcta64_updateref"
out="${wd}data/qc/"

mkdir -p "${out}plots"
for chr in {1..22}; do
  # TODO: check encoding of alleles (1234 -> ACGT)
  outdir="${out}chr${chr}/"
  mkdir ${outdir}
  # create reference frequencies
  ${gcta} --bfile ${ref_dir}${ref_stem}${chr} --freq --out ${outdir}${ref_stem}${chr}
  # ignore SNPs that are not common between reference and target
  ${gcta_ref} --bfile ${trg_dir}${trg_stem}               \
    --update-ref-allele "${outdir}${ref_stem}${chr}.freq" \
    --out "${outdir}${trg_stem}_update"                   \
    --freq | grep -v Ignore
  # TODO: pipe grep output into a .txt, and repeat call excluding SNPs

  if [ $chr = 22 ]; then
    Rscript "${wd}exe/qc/CheckStrand.r"    \
      "${outdir}${ref_stem}${chr}.freq"    \
      "${outdir}${trg_stem}_update.freq"   \
      "${out}plots/${trg_stem}_${chr}.pdf" \
      "reference"                          \
      "target"
  fi

  # flip alleles according to strand file
  cat ${strand} | awk '{if ($5=="-") print $0}' | cut -f 1 > ${outdir}${flip_file}
  ${plink} --bfile ${trg_dir}${trg_stem} \
    --flip ${outdir}${flip_file}         \
    --out "${outdir}${trg_stem}_flip"    \
    --allow-no-sex --make-bed --noweb
  # update reference allele to match datasets
  ${gcta_ref} --bfile "${outdir}${trg_stem}_flip"         \
    --update-ref-allele "${outdir}${ref_stem}${chr}.freq" \
    --out "${outdir}${trg_stem}_update_flip"              \
    --freq | grep -v Ignore

  if [ $chr = 22 ]; then
    # plot flipped alleles against reference
    Rscript "${wd}exe/qc/CheckStrand.r"         \
      "${outdir}${ref_stem}${chr}.freq"         \
      "${outdir}${trg_stem}_update_flip.freq"   \
      "${out}plots/${trg_stem}_${chr}_flip.pdf" \
      "reference"                               \
      "target (flipped)"
    # plot flipped against unflipped alleles
    Rscript "${wd}exe/qc/CheckStrand.r"                \
      "${outdir}${trg_stem}_update.freq"               \
      "${outdir}${trg_stem}_update_flip.freq"          \
      "${out}plots/${trg_stem}_${chr}_target_flip.pdf" \
      "target"                                         \
      "target (flipped)"
  fi

  # write QC stats to file
  Rscript "${wd}exe/qc/GetAlleleFreq.r"     \
    "${outdir}${trg_stem}_update.freq"      \
    "${outdir}${trg_stem}_update_flip.freq" \
    "${outdir}${ref_stem}${chr}.freq"       \
    "${trg_dir}/${trg_stem}.bim"            \
    ${strand}                               \
    ${wd}                                   \
    "TRUE"
done
