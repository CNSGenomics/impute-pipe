#-------------------------------------------------------------------------------
# File:   CompareMaf.r
# Author: Alex Holloway
# Date:   09/01/2015
#-------------------------------------------------------------------------------
CompareMaf <- function(x, y, xlab = NULL, ylab = NULL, main = NULL) {
  # Args
  #   x: PLINK .frq file for the reference dataset.
  #   y: PLINK .frq file for the target dataset.
  snps <- x[which(x$SNP %in% y$SNP), "SNP"]
  x <- x[which(x$SNP %in% snps), ]
  y <- y[which(y$SNP %in% snps), ]
  x <- x[order(x$SNP), ]
  y <- y[order(y$SNP), ]
  plot(x$MAF, y$MAF, xlab = xlab, ylab = ylab, main = main,
       xlim = c(0, 1), ylim = c(0, 1))
}
