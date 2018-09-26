# separate contig file #

a <- read.table("4_virfinder/4_1_line_count/line_count", stringsAsFactors = F)
ctg_no <- a$V1[1]
thd <- 15000
file_no <- floor(ctg_no/thd) + 1
saveRDS(file_no, "4_virfinder/4_1_line_count/file_no.rds")

if (file_no > 1) {
  cmd1 <- paste0("for i in {1..", file_no - 1, "};do sed -n \"$((1+(i-1)*", thd, ")),$((", thd, "+(i-1)*",
                 thd, ")) p\"", " 3_cross_assembly/megahit_out/final.contigs.fa > 4_virfinder/4_2_sep_ctg/$i.fasta;done")
  cmd2 <- paste0("sed -n \"", 1 + (file_no - 1) * thd, ",", ctg_no, 
                 " p\" 3_cross_assembly/megahit_out/final.contigs.fa > 4_virfinder/4_2_sep_ctg/", file_no, ".fasta")
  system(cmd1)
  system(cmd2)
} else {
  cmd <- paste0("sed -n \"", 1 + (file_no - 1) * thd, ",", ctg_no, 
                " p\" 3_cross_assembly/megahit_out/final.contigs.fa > 4_virfinder/4_2_sep_ctg/", file_no, ".fasta")
  system(cmd)
}
