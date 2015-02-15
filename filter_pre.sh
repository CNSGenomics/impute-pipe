#!/bin/bash

#$ -N pre_filter
#$ -S /bin/bash
#$ -cwd
#$ -o job_reports/
#$ -e job_reports/
#$ -l h_vmem=4G

source parameters.sh

plink2 --noweb --bfile ${rawdata} --hwe ${filterHWE} --maf ${filterMAF} --geno ${filtergeno} --mind ${filtermind} --exclude "${out}exclude.txt" --make-bed --out "${rawdata}_filter"
