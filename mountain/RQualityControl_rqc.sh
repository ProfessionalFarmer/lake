#! /bin/bash

# http://bioconductor.org/packages/release/bioc/manuals/Rqc/man/Rqc.pdf
#
#http://bioconductor.org/packages/release/bioc/html/Rqc.html
#Install via Bioconductor, stable version
#source("http://bioconductor.org/biocLite.R")
#biocLite("Rqc")

#https://github.com/labbcb/Rqc
#Install via GitHub, development vertion
#install.packages("devtools")
#library(devtools)
#install_github("labbcb/Rqc")

# $1 sample name (used in regex)
# $2 a directory within which tow fastq file in 
# $3 output html path

R --vanilla <<END
library("Rqc")
rqc(path = "$2", "fastq*", sample = FALSE, n = 1e+06, group = c("$1","$1"), top = 10, pair = c(1,1), outdir = "$2", file = "rqc_report", openBrowser = FALSE, workers = multicoreWorkers())
q()
END

# the following is old version, new version is update as below
#R --vanilla <<END
#library("Rqc")
#folder = "$2"
#files <- list.files(full.names=TRUE, path=folder)
#rqc(path = folder, pattern="fastq*", sample=FALSE, outdir = "$2", file = "rqc_report", openBrowser = FALSE, workers = multicoreWorkers())
#q()
#END

mv $2/rqc_report.html $3


