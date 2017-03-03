#! /usr/bin/Rscript
# $1 input format
# $2 output png path
# $1 format
#Value	Group
#44477	Uncertain significance
#38268	Pathogenic
#30956	not provided
# Rscript scirpt.R args1 args2
# cat 201506.sig.txt | bash ~/bin/countLineRepeatNum.sh | awk 'BEGIN{print"Value\tGroup"} {printf("%d\t%s (%d)\n",$1,$2,$1)}' 

args <- commandArgs()
#args[6] is the first argments from command line
if (length(args)!=7){
   cat("\nPlease set input file path for $1\nand out png path for $2\n\n")
}  else{

library(ggplot2)

blank_theme <- theme_minimal()+
  theme(
  axis.title.x = element_blank(),
  axis.title.y = element_blank(),
  panel.border = element_blank(),
  panel.grid=element_blank(),
  axis.ticks = element_blank(),
  plot.title=element_text(size=14, face="bold")
  )


df=read.table(args[6],header=TRUE,sep="\t")
# get header name
group=colnames(df)[2]
value=colnames(df)[1]
# rename header
colnames(df)=c("Value","Group")

bp<- ggplot(df, aes(x="", y=Value, fill=Group)) + geom_bar(width = 1, stat = "identity")
# convert to pie and add legend title
pie <- bp + coord_polar("y", start=0) + guides(fill=guide_legend(title=group))

# 当类型小于8个的时候，这个颜色比较好看use brewer color palettes 
# pie <- pie + scale_fill_brewer(palette="Dark2") 

fig = pie + blank_theme +  theme(axis.text.x=element_blank()) 

# draw
png(filename=args[7],width=2800,height=1600,units = "px",res=300)
# 如果不加print，则不输出图片
print(fig)
dev.off()

}






