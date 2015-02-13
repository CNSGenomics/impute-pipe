WriteAlleleFreq <- function(trg, flip, ref, bim, strand, wd, plink = FALSE) {
  # Combine allele frequency output for raw data, strand flipped data, and a
  # reference panel.
  #
  # Args:
  #   trg: path to target .frq or .freq file.
  #   flip: path to flipped target .frq or .freq file.
  #   ref: path to reference panel .frq or .freq file.
  #   bim: path to target dataset .bim file.
  #   strand: path to strand file, used to flip target data.
  #   wd: path to working directory.
  #   plink: boolean are the frequency files in PLINK format.
  #
  # Returns:
  #   data.frame of frequency information for common SNPs.
  if (plink) {
    trg.frq  <- read.table(trg, header = TRUE)
    flip.frq <- read.table(flip, header = TRUE)
    ref.frq  <- read.table(ref, header = TRUE)
  } else {
    # must be GCTA
    trg.frq  <- read.table(trg,  col.names = c("SNP", "ALLELE", "MAF"))
    flip.frq <- read.table(flip, col.names = c("SNP", "ALLELE", "MAF"))
    ref.frq  <- read.table(ref,  col.names = c("SNP", "ALLELE", "MAF"))
  }
  bim     <- read.table(bim, col.names = c("CHR", "SNP", "CM", "POS", "A1", "A2"))
  # TODO: strand column names
  strand  <- read.table(strand, sep = "\t")
  outpath <- paste0(wd, "data/qc")
  # subset all data files for consistency
  strand.sub <- strand[which(strand[, 1] %in% ref.frq$SNP), ]
  strand.sub <- strand.sub[order(strand.sub[, 1]), ]
  flip.sub   <- flip.frq[which(flip.frq$SNP %in% strand.sub[, 1]), ]
  flip.sub   <- flip.sub[order(flip.sub$SNP), ]
  trg.sub    <- trg.frq[which(trg.frq$SNP %in% flip.sub$SNP), ]
  trg.sub    <- trg.sub[order(trg.sub$SNP), ]
  ref.sub    <- ref.frq[which(ref.frq$SNP %in% trg.sub$SNP), ]
  ref.sub    <- ref.sub[order(ref.sub$SNP), ]
  strand.sub <- strand.sub[which(strand.sub[, 1] %in% ref.sub$SNP), ]
  strand.sub <- strand.sub[order(strand.sub[, 1]), ]
  bim.sub <- bim[which(bim$SNP %in% strand.sub[, 1]), ]
  bim.sub <- bim.sub[order(bim.sub$SNP), ]
  #-----------------------------------------------------------------------------
  out <- cbind(trg.sub, bim.sub$A1, bim.sub$A2,  flip.sub, ref.sub,
               strand.sub[, -c(2, 3, 4)])
  colnames(out) <- list("TRG_SNP", "TRG_ALL", "TRG_FREQ", "A1", "A2",
                        "FLIP_SNP", "FLIP_ALL", "FLIP_FREQ",
                        "REF_SNP", "REF_ALL", "REF_FREQ",
                        "STR_SNP", "STR", "ALL")
  chr  <- strsplit(basename(ref), "chr|\\.")[[1]][2]
  n    <- nrow(out)
  prop <- GetStrandStats(out)
  rm   <- GetPalindromes(out)
  outline <- c(chr, n, prop[1], prop[2], length(rm))  # concatenate output line
  if (chr == "1") {
    header <- c("CHR", "N", "CORRECT_PREFLIP", "CORRECT_POSTFLIP", "N_PALINDROMES")
    cat(header, "\n", sep = "\t", file = file.path(outpath, "strand_summary.txt"))
  }
  # append output
  cat(outline, "\n", sep = "\t", file = file.path(outpath, "strand_summary.txt"), append = TRUE)
  write.table(rm, file.path(outpath, "exclude.txt"), sep = "\n",
              quote = FALSE, col.names = FALSE, row.names = FALSE,
              append = TRUE)
  write.table(out, file.path(outpath, paste0("strand_info_", chr, ".txt")), sep = "\t",
              quote = FALSE, row.names = FALSE)
}
