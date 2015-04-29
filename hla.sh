#!/bin/bash

#$ -N hla_imp
#$ -S /bin/bash
#$ -cwd
#$ -o job_reports/
#$ -e job_reports/
#$ -l h_vmem=60G

##################################################################################################
# Impute the HLA region of chromosome 6 independently 
# Using SNP2HLA software
# Should be run after strand align
# Output in /data/imputation/hla/
##################################################################################################

source parameters.sh

SNP2HLA=/ibscratch/wrayvisscher/reference_data/SNP2HLA_package_v1.0.3/SNP2HLA
T1DMREF=/ibscratch/wrayvisscher/reference_data/SNP2HLA_package_v1.0.3/SNP2HLA/T1DGC_REF
wd=`pwd`"/"
output=${wd}data/imputed/hla
GENO=${wd}data/target/${targetstem}

if [ ! -d "${output}" ]; then
    mkdir ${output}
fi
if [ ! -d "${output}/tmp" ]; then
    mkdir ${output}/tmp
fi

plink --noweb --allow-no-sex --bfile ${GENO} --chr 6 --make-bed --out $output/tmp/${targetstem}

plink --noweb --allow-no-sex --bfile ${output}/tmp/${targetstem} --make-bed --out $output/${targetstem}

${SNP2HLA}/SNP2HLA.csh ${output}/tmp/${targetstem} ${T1DMREF} ${output}/${targetstem} plink 32000 1000 


