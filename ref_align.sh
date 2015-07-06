#!/bin/bash

#$ -N sort
#$ -t 1-22
#$ -S /bin/bash
#$ -cwd
#$ -o job_reports/
#$ -e job_reports/
#$ -l h_vmem=8G

# This script will take a binary plink file and:

# 1. extract chromosome to text file
# 2. align to reference

set -e

if [[ -n "${1}" ]]; then
  echo ${1}
  SGE_TASK_ID=${1}
fi

chr=${SGE_TASK_ID}
wd=`pwd`"/"

source parameters.sh



if [ ! -d "${hapdatadir}" ]; then
  mkdir ${hapdatadir}
fi
if [ ! -d "${targetdatadir}" ]; then
  mkdir ${targetdatadir}
fi
if [ ! -d "${impdatadir}" ]; then
  mkdir ${impdatadir}
fi


cd ${targetdatadir}





# 1. extract chromosomes, perform cleaning and alignment to reference data




# extract chromosome 
${plink} --noweb --bfile ${originaldata} --chr ${chr} --make-bed --out ${chrdata}

# perform liftOver
# This will lead to new positions, some new SNP names (particularly HLA region of chr 6 from hg18 to hg19)
# First get new positions - then update the plink files
# Then read in the bim file and match SNP IDs to positions
# Then do the other alignment stuff.

awk '{ print "chr"$1, $4-1, $4, $2 }' ${chrdata}.bim > ${chrdata}.lo.orig
${liftOver} ${chrdata}.lo.orig ${lochain} ${chrdata}.lo.new ${chrdata}.lo.unmapped

# 1. remove unmapped SNPs
grep -v "#" ${chrdata}.lo.unmapped | cut -f 4 > ${chrdata}.lo.exclude
${plink} --noweb --bfile ${chrdata} --exclude ${chrdata}.lo.exclude --make-bed --out ${chrdata}

# 2. reposition SNPs
awk '{print $4, $3}' ${chrdata}.lo.new > ${chrdata}.lo.update-map
${plink} --noweb --bfile ${chrdata} --update-map ${chrdata}.lo.update-map --make-bed --out ${chrdata}
${plink} --noweb --bfile ${chrdata} --make-bed --out ${chrdata}

# 3. Some SNP positions will match but SNP IDs will have changed
cp ${chrdata}.bim ${chrdata}.bim.orig-snp-ids
R --no-save --args ${chrdata}.bim ${reflegend} ${chrdata}.newpos ${refphase} < ${rs_updateR}

# Remove duplicated SNPs
R --no-save --args ${chrdata} ${plink} < ${removedupsnpsR}

# find SNPs not present in reference, create new SNP order based on reference positions
# R --no-save --args ${chrdata}.bim ${reflegend} ${chrdata}.newpos < ${positionsR}
if [ -e ${chrdata}.newpos.missingsnps ]; then
	${plink} --noweb --bfile ${chrdata} --exclude ${chrdata}.newpos.missingsnps --make-bed --out ${chrdata}
fi

# update sample SNP orders and positions
${plink} --noweb --bfile ${chrdata} --update-map ${chrdata}.newpos --make-bed --out ${chrdata}
${plink} --noweb --bfile ${chrdata} --make-bed --out ${chrdata}


# add genetic distances to bim file

R --no-save --args ${chrdata}.bim ${refgmap} < ${genetdistR}
${plink} --noweb --bfile ${chrdata} --exclude ${chrdata}.bim.nogenet --make-bed --out ${chrdata}


exit

