#!/bin/bash

#$ -N splitsamples
#$ -o job_reports/
#$ -e job_reports/
#$ -S /bin/bash
#$ -cwd
#$ -l h_vmem=10G

#Split into max 15000 sample sized chunks of plink data

wd=`pwd`"/"
source ${wd}parameters.sh

cd ${targetdatadir}

split -l ${splitsamplesize} ${originaldata}.fam ${originaldata}"_n" -d

set=0
for samplegroup in $(ls -1 ${originaldata}"_n"*)
do
    echo $samplegroup
    ${plink2} --bfile ${originaldata} --keep $samplegroup --make-bed --out ${originaldata}_set${set}
    set=$((set+1))
done

