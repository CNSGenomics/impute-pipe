#!/bin/sh

#A script for updating a binary ped file using one of Will's strand files
#NRR 17th Jan 2012

#V2 13th Feb 2012. Added code to retain only SNPs in the strand file

#Required parameters:
#1. The original bed stem (not including file extension suffix)
#2. The strand file to apply
#3. The new stem for output
#Result: A new bed file (etc) using the new stem

set -e

wd=`pwd`"/"
source ${wd}parameters.sh

if [ -f ${originaldata}.bed ];
then
   stem=${originaldata}
else
   stem=${rawdata}
fi

outstem=${originaldata}

echo Input stem is $stem
echo Strand file is $strand_file
echo Output stem is $outstem

#Cut the strand file into a series of Plink slices
chr_file=$strand_file.chr
pos_file=$strand_file.pos
flip_file=$strand_file.flip
cat $strand_file | cut -f 1,2 > $chr_file
cat $strand_file | cut -f 1,3 > $pos_file
cat $strand_file | awk '($4=="-" || $5=="-") { print $1 }' > $flip_file
flip_len=$(wc -l $flip_file | cut -d ' ' -f 1)
if (($flip_len < 1)); then
    echo "Warning: No strands will be flipped" >&2
else
    echo "$flip_len strands will be flipped" 
fi



#Because Plink only allows you to update one attribute at a time, we need lots of temp
#Plink files
temp_prefix=TEMP_FILE_XX72262628_
temp1=$temp_prefix"1"
temp2=$temp_prefix"2"
temp3=$temp_prefix"3"

#1. Apply the chr
qsub -l h_vmem=40G -b y -cwd -N plink1 ${plink} --noweb --allow-no-sex --bfile $stem --update-map $chr_file --update-chr --make-bed --out $temp1
#2. Apply the pos
qsub -l h_vmem=40G -b y -cwd -N plink2 -hold_jid plink1 ${plink} --noweb --allow-no-sex --bfile $temp1 --update-map $pos_file --make-bed --out $temp2
#3. Apply the flip
qsub -l h_vmem=40G -b y -cwd -N plink3 -hold_jid plink1,plink2 ${plink} --noweb --allow-no-sex --bfile $stem --flip $flip_file --make-bed --out $temp3
#4. Extract the SNPs in the pos file, we don't want SNPs that aren't in the strand file
qsub -l h_vmem=40G -b y -cwd -N plink4 -hold_jid plink1,plink2,plink3 ${plink} --noweb --allow-no-sex --bfile $temp3 --extract $pos_file --make-bed --out $outstem

# Remove any duplicated SNPs or duplicated positions
# R --no-save --args ${plink} ${outstem} < ${cleanupR}

#Now delete any temporary artefacts produced
qsub -b y -cwd -e job_reports/ -hold_jid plink1,plink2,plink3,plink4 rm -f $temp_prefix*


