# synthesize vf results #

library(VirFinder)

file_no <- readRDS("4_virfinder/4_1_line_count/file_no.rds")
datapath <- "4_virfinder/4_3_vf_sep/"

vf <- readRDS(paste0(datapath, "vf_results_", 1, ".rds"))
if (file_no > 1) {
  for (i in 2:file_no) {
    vf0 <- readRDS(paste0(datapath, "vf_results_", i, ".rds"))
    vf <- rbind(vf, vf0)
  }
}

datapath <- "4_virfinder/4_4_vf_summary/"

vf$qvalue <- VF.qvalue(vf$pvalue) 
saveRDS(vf, paste0(datapath, "vf_results.rds"))

vf_filter <- subset(vf, qvalue < 0.2)
write.table(vf_filter, paste0(datapath, "vf_qv_0.2"), quote = F, row.names = F)
