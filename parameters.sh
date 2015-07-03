#!/usr/bin/env bash

plink="${wd}exe/plink"
shapeit2="${wd}exe/shapeit"
impute2="${wd}exe/impute2"
liftOver="${wd}exe/liftOver"
vote_phase="${wd}exe/vote-phase"
bgl_to_ped="${wd}exe/bgl_to_ped"
gcta="${wd}exe/gcta64"
gcta_ref="${wd}exe/gcta64_updateref"

positionsR="${wd}exe/positions.R"
modmarkersR="${wd}exe/modmarkers.R"
rs_updateR="${wd}exe/rs_update.R"
splitbimR="${wd}exe/splitbim.R"
genetdistR="${wd}exe/genetdist.R"
makeheaderR="${wd}exe/makeheader.R"
gprobs2beagle="${wd}exe/gprobs2beagle.jar"
imp2plink="${wd}exe/imp2plink.sh"
stitchplinkR="${wd}exe/stitchplink.R"
removedupsnpsR="${wd}exe/removedupsnps.R"
cleanupR="${wd}exe/cleanup.R"
filterinfoR="${wd}exe/filterinfo.R"

#-------------------------------------------------------------------------------
# TO BE EDITED BY USER
#-------------------------------------------------------------------------------
targetdatadir="${wd}data/target/chr${chr}/"
hapdatadir="${wd}data/haplotypes/chr${chr}/"
impdatadir="${wd}data/imputed/chr${chr}/"
refdatadir="/ibscratch/wrayvisscher/reference_data/1000_genomes/ALL_1000G_phase1integrated_v3_impute/"
qcdatadir="${wd}data/qc/"

# change for each run if splitting imputation into sets #eg. _set0, _set1
# otherwise leave blank for normal imputation
sampleset=""
splitsamplesize=15000 

# file stems for quality control (see `check_strand.sh`)
refstem=""
targetstem=""

# Reference data file locations
reflegend="${refdatadir}ALL_1000G_phase1integrated_v3_chr${chr}_impute.legend.gz"
refhaps="${refdatadir}ALL_1000G_phase1integrated_v3_chr${chr}_impute.hap.gz"
refgmap="${refdatadir}genetic_map_chr${chr}_combined_b37.txt"

# Reference data phase
refphase=1

# impute2 interval (default is 5Mb)
interval=5000000

# Target data information (after cleaning using strand_align.sh)
rawdata="${wd}data/target/dataname"
originaldata="${wd}data/target/dataname_filter"${sampleset}
chrdata="DAT${chr}"${sampleset}
shortname="dat${chr}"${sampleset}
strand_file="${wd}data/target/strand/chipname.strand"

#Haplotype files
hapout="${hapdatadir}${chrdata}"

# LiftOver chain
lochain="${wd}exe/hg18ToHg19.over.chain"

# How many SNPs in the original data
nsnp=`wc -l ${originaldata}.bim | awk '{print $1}'`

# Output name
plink1kg="dataname_1kg_p1v3_${chr}"

# Filtering thresholds
filterMAF="0.01"
filterHWE="0.01"
filtergeno="0.02"
filtermind="0.1"
filterInfo="0.8"

# Filtering output name
filtername="${plink1kg}_maf${filterMAF}_hwe${filterHWE}"
