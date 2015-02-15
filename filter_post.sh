#!/bin/bash

#$ -N filter2
#$ -t 1-22
#$ -S /bin/bash
#$ -cwd
#$ -o job_reports/
#$ -e job_reports/
#$ -l h_vmem=4G

#Filter imputation results by maf and hwe

set -e

if [[ -n "${1}" ]]; then
  echo ${1}
  SGE_TASK_ID=${1}
fi

chr=$SGE_TASK_ID
fname="SNPs_fil${chr}"

source parameters.sh

plink2 --noweb --bfile ${impdatadir}${plink1kg} --hwe ${filterHWE} --maf ${filterMAF} --make-bed --out ${impdatadir}${filtername} 

#Optional Additional Info Filter: Write snp list based on info (r2) value, then filter those values 
#zcat ${impdatadir}${plink1kg}_info.txt.gz | awk -v mininfo=${filterInfo} '{ if(NR == 1 || ($5 >= mininfo)) {print $0}}' | gzip > ${impdatadir}${filterInfo}_info.txt.gz
#zcat ${impdatadir}${filterInfo}_info.txt.gz | tail -n +2 | cut -d " " -f 2 | uniq > ${impdatadir}"_info"${filterInfo}.keepsnps
#plink2 --noweb --bfile ${impdatadir}${filtername} --extract ${impdatadir}"_info"${filterInfo}.keepsnps --make-bed --out ${impdatadir}${filtername}"_info"${filterInfo}

