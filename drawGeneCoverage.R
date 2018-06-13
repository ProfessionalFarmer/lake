#! /usr/bin/Rscript
# Author: Jason Zhu. Created on: 20180613
# bedtools coverage -a /share/apps/reference/bed/cardio_gene_bed/$gene.bed -b unqualitygene/$gene.bed -d | | awk 'BEGIN{print "POS\tDEPTH" }{print NR"\t"$6}' > hist.txt
# $1 FILE: pos(1 based)\t depth
# $2 output figure path
# $3 title 
args <- commandArgs()

if (length(args) <=7 ){
   cat("\nPlease set input hist file for $1\nand out png path for $2\n\n")
}  else{
    if(is.na(args[8])){
	args[8] <- ''
    }
    library(ggplot2)
    data <- read.table(args[6],header=T)
    png(args[7])
    p <- ggplot(data=data,aes(x=POS,y=DEPTH)) + 
	geom_line() + labs(title=args[8]) + theme(plot.title = element_text(hjust = 0.5))
    print (p)
    dev.off()
}

