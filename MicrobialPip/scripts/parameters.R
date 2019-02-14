# extract sample name from reads files & get centrifuge data path#

args <- commandArgs(trailingOnly = TRUE)
print(args)

if (args[1] == "P") {
  datapath <- args[2]
  pe1 <- args[3]
  pe2 <- args[4]
  fq <- args[5]
  ctf <- args[6]
  mcl <- args[7]
  
  system(paste0("ls ", datapath, " > docs/reads_name"))
  
  rn <- read.table("docs/reads_name", stringsAsFactors = F)
  sample <- matrix("0", nrow(rn), 1)
  for (i in 1:nrow(rn)) {
    if (grepl(pe1, rn$V1[i])) {
      sample[i] <- strsplit(rn$V1[i], pe1)[[1]][1]
    } else {
      sample[i] <- strsplit(rn$V1[i], pe2)[[1]][1]
    }
  }
  
  sample <- unique(sample)
  write.table(sample, "docs/sample", quote = F, row.names = F, col.names = F)
  write.table(args[c(2:6)], "docs/parameters", quote = F, row.names = F, col.names = F)
} else {
  datapath <- args[2]
  fq <- args[3]
  ctf <- args[4]
  mcl <- args[5]
  
  system(paste0("ls ", datapath, " > docs/reads_name"))
  
  rn <- read.table("docs/reads_name", stringsAsFactors = F)
  sample <- matrix("0", nrow(rn), 1)
  for (i in 1:nrow(rn)) {
    sample[i] <- strsplit(rn$V1[i], fq)[[1]][1]
  }
  
  write.table(sample, "docs/sample", quote = F, row.names = F, col.names = F)
  write.table(args[c(2:4)], "docs/parameters", quote = F, row.names = F, col.names = F)
}
