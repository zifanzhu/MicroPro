# extract unknown viral organism abundance #

library(ShortRead)
library(data.table)

a <- read.table("docs/sample", stringsAsFactors = F)

bc <- read.table("viral_3_binning/bin_count", stringsAsFactors = F)
bc <- bc$V1[1]

x <- read.table(paste0("viral_2_map_to_vf_filtered_ctg/properly_paired_mapped/",
                       a$V1[1], ".idx"), stringsAsFactors = F)
x<-x[-nrow(x),]
contig_name<-x$V1

feat <- matrix(0, nrow = nrow(a), ncol = length(contig_name))
colnames(feat)<-contig_name
rownames(feat)<-a$V1

for (i in 1:nrow(a)) {
  cat(paste0("processing sample ", a$V1[i], "\n"))
  x <- read.table(paste0("viral_2_map_to_vf_filtered_ctg/properly_paired_mapped/",
                         a$V1[i],".idx"), stringsAsFactors = F)
  x <- x[-nrow(x),]
  feat[i, ] <- x$V3/x$V2
}

saveRDS(feat, "docs/vf_filtered_contigs_length_normalized_read_counts.rds")

if (bc < 10) {

  if (length(which(apply(feat, 2, sum) == 0)) != 0){
    feat <- feat[, -which(apply(feat, 2, sum) == 0)]
  }

  abund <- feat
  for (i in 1:nrow(a)) {
    s <- sum(abund[i, ])
    if (s != 0) {
      abund[i, ] <- abund[i, ]/s
    }
  }
  abund <- as.data.frame(abund)
  saveRDS(abund, "res/unknown_viral_abundance.rds")
  write.csv(abund, "res/unknown_viral_abundance.csv", quote = F)
} else {
  bin <- list()
  for (i in 1:bc) {
    aa <- readFasta(paste0("viral_3_binning/bins_dir/bin.", i, ".fa"))
    bin[[i]] <- as.vector((id(aa)))
  }

  contig <- readFasta("viral_1_vf_filtered_contigs/vf_filtered_contig.fasta")
  name <- as.vector(id(contig))

  s_name <- vector("character", length(contig))
  for (i in 1:length(contig)) {
    s_name[i] <- strsplit(name[i], " ")[[1]][1]
  }

  result_bin <- matrix(0, 1, length(contig))
  colnames(result_bin) <- s_name
  for (i in 1:bc) {
    b <- bin[[i]]
    result_bin[1,b]<-i
  }

  f <- data.table(bin = result_bin[1, ], t(feat))
  feat_bin <- f[bin != 0, lapply(.SD, mean), by = bin][order(bin)]
  feat_bin <- t(feat_bin[, -1])
  colnames(feat_bin) <- 1:bc

  if (length(which(apply(feat_bin,2,sum)==0)) != 0){
    feat_bin <- feat_bin[, -which(apply(feat_bin,2,sum) == 0)]
  }

  for (i in 1:nrow(a)){
    s <- sum(feat_bin[i, ])
    if (s != 0) {
      feat_bin[i, ] <- feat_bin[i, ]/s
    }
  }

  saveRDS(feat_bin, "res/unknown_viral_abundance.rds")
  write.csv(feat_bin, "res/unknown_viral_abundance.csv", quote = F)
}

# output combined abundance table #

all <- fread("docs/wc_all")
unmapped <- fread("docs/wc_unmapped")
ump <- sum(all$V1) / unmapped$V1[1]
ctg <- fread("4_virfinder/4_1_line_count/line_count")
v_ctg <- fread("4_virfinder/4_4_vf_summary/wc_vf_filtered")
vp <- v_ctg / ctg

k_abund <- readRDS("res/centrifuge_viral_species_abundance.rds")
uk_abund <- readRDS("res/unknown_viral_abundance.rds")
abund <- cbind(k_abund * (1 - ump), uk_abund * ump * vp)
saveRDS(abund, "res/combined_viral_abundance.rds")
write.csv(abund, "res/combined_viral_abundance.csv", quote = F)
