#-------------------------------------------------------------------------------
# Auxiliary functions for performing pre-imputation quality control checks.
#-------------------------------------------------------------------------------
GetPalindromes <- function(strand.info) {
  x  <- paste0(strand.info$A1, strand.info$A2)
  rm <- strand.info[which(x == "AT" | x == "TA" | x == "CG" | x == "GC"), "TRG_SNP"]
  return(rm)
}

GetStrandStats <- function(strand.info) {
  correct.preflip  <- PercentUnflipped(strand.info)
  correct.postflip <- PercentFlipped(strand.info)
  if (correct.preflip > 0.95) {
    msg <- paste0("High allelic concordance (", correct.preflip,
                  ") detected before strand flipping.")
  } else if (correct.postflip > 0.95) {
    msg <- paste0("High allelic concordance (", correct.postflip,
                  ") detected after strand flipping.")
  } else {
    msg <- paste0("Indeterminate allelic concordance detected before and after ",
                  "strand flipping. Check strand alignment, and view plots in ",
                  "`data/qc/plots`.")
  }
  print(msg)
  return(c(correct.preflip, correct.postflip))
}

PercentUnflipped <- function(x) {
  length(which(x$TRG_ALL == x$REF_ALL)) / nrow(x)
}

PercentFlipped <- function(x) {
  length(which(x$FLIP_ALL == x$REF_ALL)) / nrow(x)
}

RecodeAlleles <- function(strand.info) {
  out[out == 1] <- "A"
  out[out == 2] <- "C"
  out[out == 3] <- "G"
  out[out == 4] <- "T"
}
