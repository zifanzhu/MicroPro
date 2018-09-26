# extract centrifuge species abundance #

a <- read.table("docs/sample", stringsAsFactors = F)
datapath <- "1_centrifuge/"
maxid <- 2071980
for (i in 1:nrow(a)) {
  x <- read.delim(paste0(datapath, a$V1[i], "_report"))
  x <- subset(x, taxRank == "species")
  if (max(x$taxID) > maxid) {
    maxid <- max(x$taxID)
  }
}

feat <- matrix(0, nrow(a), maxid)
colnames(feat) <- 1:maxid
rownames(feat) <- a$V1

for (i in 1:nrow(a)) {
  cat(paste0("processing sample ", a$V1[i], "\n"))
  x <- read.delim(paste0(datapath, a$V1[i], "_report"))
  x <- subset(x, taxRank == "species")
  for (j in 1:nrow(x)) {
    feat[a$V1[i],x$taxID[j]] <- x$abundance[j]
  }
}

zero <- which(apply(feat, 2, sum) == 0)
if (length(zero) != 0){
  feat <- feat[ ,-zero]
}

feat<-as.data.frame(feat)
write.csv(feat, "res/centrifuge_species_abundance.csv", quote = F)
saveRDS(feat, "res/centrifuge_species_abundance.rds")
