source parameters.sh
plink2="${wd}exe/plink2"

> merge.set
for n in {2..22}
do
  prefix="${wd}data/imputed/chr${n}/${plink1kg}${n}"
  echo ${prefix}.bed  ${prefix}.bim  ${prefix}.fam >> merge.set
done

n=1
prefix="${wd}data/imputed/chr${n}/${plink1kg}${n}"
${plink2} --bfile "${prefix}" --merge-list merge.set --make-bed --out outname_1kg 
