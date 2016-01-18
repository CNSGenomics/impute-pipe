#!/bin/bash

#$ -N hap
#$ -t 1-22
#$ -S /bin/bash
#$ -cwd
#$ -o job_reports/
#$ -e job_reports/
#$ -l h_vmem=4G
#$ -pe onehost 8

# This script will take a reference-aligned binary plink file and:
# 1. For each chromosome perform shapeit

set -e
if [ -n "${1}" ]; then
    SGE_TASK_ID=${1}
fi

#echo "Running on host: ${HOSTNAME}"

chr=${SGE_TASK_ID}
wd=`pwd`"/"
source parameters.sh

if [ ! -d "${hapdatadir}" ]; then
    mkdir ${hapdatadir}
fi

if [ ! -d "${impdatadir}" ]; then
    mkdir ${impdatadir}
fi

cd ${targetdatadir}
flags="--thread 8 --noped"

#if [ "${chr}" -eq "23" ]; then
#    flags="$flags --chrX"
#fi

# If less than 100 indivduals, use reference panel to phase
indv=$(wc -l ${targetdatadir}/${chrdata}.fam | cut -f 1 -d ' ')
echo "There are $indv individuals"
minindiv=100
if [ $indv -lt $minindiv ]; then
    flags="$flags --input-ref ${refhaps} ${reflegend} ${refsample}"
    echo "Using reference set to phase data" #this can be a bit slower
fi

${shapeit2} --input-bed ${chrdata}.bed ${chrdata}.bim ${chrdata}.fam --input-map ${refgmap} --output-max ${hapout}.haps ${hapout}.sample ${flags}
