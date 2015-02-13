#-------------------------------------------------------------------------------
# Arg-parsing and environment setup script to process pre-imputation QC stats.
#-------------------------------------------------------------------------------
args <- commandArgs(TRUE)
trg  <- args[1]
flip <- args[2]
ref  <- args[3]
bim  <- args[4]
str  <- args[5]
wd   <- args[6]
flag <- as.logical(args[7])
#-------------------------------------------------------------------------------
setwd(wd)
source("exe/AuxiliaryQC.r")
source("exe/WriteAlleleFreq.r")
WriteAlleleFreq(trg, flip, ref, bim, str, wd, flag)
