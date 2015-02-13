#-------------------------------------------------------------------------------
# Merge imputation quality info files for all chromosomes in a dataset
# (requires data to be stitched first using `stitch_plink.sh`).
#-------------------------------------------------------------------------------
wd=`pwd`"/"
dir="${wd}data/imputed/"
stem="file_stem"
out="out_name_info.txt.gz"

zcat ${dir}"1/"${stem}"1_info.txt.gz" > ${wd}${out}

for chr in {2..22}; do
  zcat "${dir}chr${chr}/${stem}${chr}_info.txt.gz" | sed "1 d" >> ${wd}${out}
done
