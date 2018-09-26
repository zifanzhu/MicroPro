# extract unknown organism abundance #

library(ShortRead)

a <- read.table("docs/sample", stringsAsFactors = F)

bc <- read.table("5_binning/bin_count", stringsAsFactors = F)
bc <- bc$V1[1]

x <- read.table(paste0("4_map_to_contigs/properly_paired_mapped/", 
                       a$V1[1], ".idx"), stringsAsFactors = F)
x<-x[-nrow(x),]
contig_name<-x$V1

feat <- matrix(0, nrow = nrow(a), ncol = length(contig_name))
colnames(feat)<-contig_name
rownames(feat)<-a$V1

for (i in 1:nrow(a)) {
  cat(paste0("processing sample ", a$V1[i], "\n"))
  x <- read.table(paste0("4_map_to_contigs/properly_paired_mapped/",
                         a$V1[i],".idx"), stringsAsFactors = F)
  x <- x[-nrow(x),]
  for (j in 1:length(contig_name)) {
    feat[i, j] <- x$V3[j]/x$V2[j]
  }
}

saveRDS(feat, "docs/contigs_length_normalized_read_counts.rds")

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
  saveRDS(abund, "res/unknown_abundance.rds")
  write.csv(abund, "res/unknown_abundance.rds", quote = F)
} else {
  bin <- list()
  for (i in 1:bc) {
    aa <- readFasta(paste0("5_binning/bins_dir/bin.", i, ".fa"))
    bin[[i]] <- as.vector((id(aa)))
  }
  
  contig <- readFasta("3_cross_assembly/megahit_out/final.contigs.fa")
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
  
  feat_bin <- matrix(0, nrow(a), bc)
  colnames(feat_bin) <- 1:bc 
  for (i in 1:bc){
    fl <- as.matrix(feat[, which(result_bin[1, ] == i)])
    feat_bin[, i] <- apply(fl, 1, mean)
  }
  
  if (length(which(apply(feat_bin,2,sum)==0)) != 0){
    feat_bin <- feat_bin[, -which(apply(feat_bin,2,sum) == 0)]
  }
  
  for (i in 1:nrow(a)){
    s <- sum(feat_bin[i, ])
    if (s != 0) {
      feat_bin[i, ] <- feat_bin[i, ]/s
    }
  }
  
  saveRDS(feat_bin, "res/unknown_abundance.rds")
  write.csv(feat_bin, "res/unknown_abundance.csv", quote = F)
}
