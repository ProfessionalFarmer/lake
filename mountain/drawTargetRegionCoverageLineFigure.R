#! /usr/bin/Rscript
# Author: Jason Zhu. Created on: 20160820
# Modified on: 20180130
# # Clone from https://gist.github.com/stephenturner/9396409   Thanks 
# $1: bedtools coverage output file should be in the same directory
# file should suffix with "hist.all.txt$"
# input file from: bedtools coverage -hist -b  samp.01.bam -a target_regions.bed | grep ^all > samp.01.bam.hist.all.txt  or bedtools genomecov -ibam ../merge.bam -g genome.file.txt | grep ^genome > genome.cov
# bedtools -g and -sorted should be noticed
# $2: png figure output path
# Ref: http://www.gettinggeneticsdone.com/2014/03/visualize-coverage-exome-targeted-ngs-bedtools.html

args <- commandArgs()

if (length(args)!=7){
   cat("\nPlease set input directory for $1\nand out png path for $2\n\n")
}  else{

setwd(args[6])

# Get a list of the bedtools output files you'd like to read in
print(files <- list.files(pattern="hist.all.txt$"))

# Optional, create short sample names from the filenames. 
# For example, in this experiment, my sample filenames might look like this:
# prefixToTrash-01.pe.on.pos.dedup.realigned.recalibrated.bam
# prefixToTrash-02.pe.on.pos.dedup.realigned.recalibrated.bam
# prefixToTrash-03.pe.on.pos.dedup.realigned.recalibrated.bam
# This regular expression leaves me with "samp01", "samp02", and "samp03" in the legend.
print(labs <- paste("", gsub(".hist.all.txt", "", files, perl=TRUE), sep=""))


# Create lists to hold coverage and cumulative coverage for each alignment,
# and read the data into these lists.
cov <- list()
cov_cumul <- list()
for (i in 1:length(files)) {
    cov[[i]] <- read.table(files[i])
    cov_cumul[[i]] <- 1-cumsum(cov[[i]][,5])
}

# Pick some colors
# Ugly:
# cols <- 1:length(cov)
# Prettier:
# ?colorRampPalette
# display.brewer.all()
library(RColorBrewer)
library(ggsci)
if(length(cov)<7){
cols <- brewer.pal(length(cov), "Dark2")
}else{
cols <- pal_d3("category20",alpha = 0.8)(20)
}
#cols <- colorRampPalette(brewer.pal(8, "Accent"))(length(cov))

# Save the graph to a file
#png("exome-coverage-plots.png", h=1000, w=1000, pointsize=20)
png(args[7], h=1000, w=1000, pointsize=20)

# Create plot area, but do not plot anything. Add gridlines and axis labels.
plot(cov[[1]][2:401, 2], cov_cumul[[1]][1:400], type='n', xlab="Depth", ylab="Fraction of capture target bases \u2265 depth", ylim=c(0,1.0), main="Target Region Coverage")
abline(v = 20, col = "gray60")
abline(v = 50, col = "gray60")
abline(v = 80, col = "gray60")
abline(v = 100, col = "gray60")
abline(h = 0.50, col = "gray60")
abline(h = 0.90, col = "gray60")
axis(1, at=c(20,50,80), labels=c(20,50,80))
axis(2, at=c(0.90), labels=c(0.90))
axis(2, at=c(0.50), labels=c(0.50))

# Actually plot the data for each of the alignments (stored in the lists).
# 2018-02-26 Jason
# for (i in 1:length(cov)) points(cov[[i]][2:401, 2], cov_cumul[[i]][1:400], type='l', lwd=3, col=cols[i])
for (i in 1:length(cov)) points(c(0,cov[[i]][1:400, 2]), c(1,cov_cumul[[i]][1:400]), type='l', lwd=3, col=cols[i])

# Add a legend using the nice sample labeles rather than the full filenames.
legend("topright", legend=labs, col=cols, lty=1, lwd=4)

dev.off()

}


