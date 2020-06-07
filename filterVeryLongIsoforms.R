

args = commandArgs(T)
input.file = args[1]
output.file = args[2]
len.cutoff = 1500000

library(plyranges, lib = "/data/cache/zhongxu/R")

gff <- read_gff(input.file)
gff.tmp <- gff %>% select(transcript_id, gene_id, gene_name)
gff.tmp <- as.data.frame(gff.tmp)

pos.min <- aggregate(start ~ transcript_id, data = gff.tmp, min)
pos.max <- aggregate(end   ~ transcript_id, data = gff.tmp, max)

# 这个是在基因组上的长度，不是外显子的长度
transcript.genomic.length <- merge(pos.min,pos.max,by="transcript_id")
transcript.genomic.length$length <- transcript.genomic.length$end - transcript.genomic.length$start

# 过滤大于1500000
candidate.remove <- transcript.genomic.length[transcript.genomic.length$length > len.cutoff,]$transcript_id

gff <- gff %>% filter(! transcript_id %in% candidate.remove)
write_gff(gff, file = output.file)



