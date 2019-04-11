# extract centrifuge viral species abundance #

vir_taxid <- readRDS(paste0("docs/known_viurs_NCBI_taxid.rds"))
ctf_abund <- readRDS("res/centrifuge_abundance.rds")
vir_abund <- ctf_abund[ ,which(colnames(ctf_abund) %in% as.character(vir_taxid))]

write.csv(vir_abund, "res/centrifuge_viral_abundance.csv", quote = F)
saveRDS(vir_abund, "res/centrifuge_viral_abundance.rds")
