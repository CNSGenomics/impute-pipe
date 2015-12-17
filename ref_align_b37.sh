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
