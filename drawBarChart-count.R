#! /usr/bin/Rscript
# Author: Zhongu Zhu. Created on: 20160820
#
# Rscript scirpt.R args1 args2
# cat 201506.sig.txt | cuf -f 1 | sed '1d'
#
# $1 input format
# $2 output png path
# $1 format, no header
#exonic
#upstream
#intergenic
#ntergenic
#xonic
#xonic
#intergenic
#xonic
#TR3
#xonic
#exonic
#xonic

args <- commandArgs()
#args[6] is the first argments from command line
if (length(args)!=7){
   cat("\nPlease set input file path for $1\nand out png path for $2\n\n")
}  else{

library(ggplot2)

df=read.table(args[6],header=FALSE,sep="\t")

#Fill col is used for fill color
df$Fill=df[,1]

# get header name
group=colnames(df)[1]
# rename header
colnames(df)=c("Group","Fill")

# RColorBrewer palette chart 代表一系列具有视觉效果的颜色
# http://colorbrewer2.org/
# http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/

fig<- ggplot(df, aes(Group, fill=Fill))  + geom_bar(stat = "count") + scale_fill_brewer(palette="Dark2") + theme(axis.title.x=element_blank(), legend.position="none") 

# draw
png(filename=args[7],width=1500,height=1500,units = "px",res=300)
# 如果不加print，则不输出图片
print(fig)
dev.off()

}




