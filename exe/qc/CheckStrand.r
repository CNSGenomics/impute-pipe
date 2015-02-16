#-------------------------------------------------------------------------------
# Plot allele frequencies against each other
#-------------------------------------------------------------------------------
source("exe/qc/CompareMaf.r")
args    <- commandArgs(TRUE)
x.frq   <- args[1]  # path to GCTA .freq file for target dataset
y.frq   <- args[2]
outpath <- args[3]
xlab    <- args[4]
ylab    <- args[5]
#-------------------------------------------------------------------------------
x <- read.table(x.frq, col.names = c("SNP", "ALLELE", "MAF"))
y <- read.table(y.frq, col.names = c("SNP", "ALLELE", "MAF"))
pdf(outpath)
CompareMaf(x, y, xlab, ylab)
dev.off()
