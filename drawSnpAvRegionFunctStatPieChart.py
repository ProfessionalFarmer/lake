# -*- coding: utf-8 -*-
#! /usr/bin/python

__author__ = 'Jason'
'''
Create   on: 20160408
Modified on:
Draw pie chart. Input format: annovar.
'''

import getopt
import sys
import os

sep='\t'
empty_col='.'

def getopts():
    try:
        options,args = getopt.getopt(sys.argv[1:],"i:o:m:",[''])
        return options
    except getopt.GetoptError:
        print '''
        program.py -i <INPUT> -o <OUTPUT> -m MODE
        Support stdin
        MODE 1 Stat snp in whole genome region, 2 Stat snp function in whole exome sequencing, 3 for both. Dafault is 3 for both
        '''
        sys.exit()

def prepareGenomeRegionData(list):
    colName='Func.refGene'
    map={}
    for i,line in enumerate(list):
        t=line.split(sep)
        if i==0:
            index=t.index(colName)
            continue
        else:
            type=t[index].strip()
	    if type==empty_col: continue
            if type in map.keys():
                map[type]=map[type]+1
            else:
                map[type]=1
    map=sorted(map.iteritems(), key=lambda d:d[1], reverse = True)
    type=''
    num=''
    for item in map:
        type=type+'"%s(%d)", '%(item[0],item[1])
        num=num+'%d, '%item[1]
    type=type[:-2]
    num=num [:-2]
    return type,num


def prepareFunctionTypeInExomeData(list):
    colName='ExonicFunc.refGene'
    map={}
    for i,line in enumerate(list):
        t=line.split(sep)
        if i==0:
            index=t.index(colName)
            continue
        else:
            if len(t)-1<index:continue
            type=t[index].strip()
	    if type==empty_col: continue
            if type in map.keys():
                map[type]=map[type]+1
            else:
                map[type]=1
    map=sorted(map.iteritems(), key=lambda d:d[1], reverse = True)
    type=''
    num=''
    for item in map:
        type=type+'"%s(%d)", '%(item[0],item[1])
        num=num+'%d, '%item[1]
    type=type[:-2]
    num=num [:-2]
    return type,num

def drawSingleFigure(type,num,outpath,title):
    script_str='''#! /usr/bin/Rscript\n
library(ggplot2)
df <- data.frame(
  Type = c(%s),
  Num = c(%s)
  )
# Use a barplot to visualize the data
bp <- ggplot(df,aes(x="",y=Num,fill=Type)) + geom_bar(width=1,stat="identity")
# Create a pie chart
pie <- bp + coord_polar("y",start=0)

blank_theme <- theme_minimal()+
  theme(
  axis.title.x = element_blank(),
  axis.title.y = element_blank(),
  panel.border = element_blank(),
  panel.grid=element_blank(),
  axis.ticks = element_blank(),
  plot.title=element_text(size=14, face="bold")
  )

png(filename="%s",width=1800,height=1300,units = "px",res=200)
pie + blank_theme + theme(axis.text.x=element_blank()) + labs(title = "%s")
#labs(x="x",y="y",title = "geom_line")
dev.off()
''' % (type,num,outpath,title)
    return script_str

def drawTwoCharInOneFigure(type_g,num_g,type_e,num_e,outpath,title1,title2):
    script_str='''#! /usr/bin/Rscript\n
library(ggplot2)
library(grid)
df1 <- data.frame(
  Type = c(%s),
  Num = c(%s)
  )
df2 <- data.frame(
  Type = c(%s),
  Num = c(%s)
  )
blank_theme <- theme_minimal()+
  theme(
  axis.title.x = element_blank(),
  axis.title.y = element_blank(),
  panel.border = element_blank(),
  panel.grid=element_blank(),
  axis.ticks = element_blank(),
  plot.title=element_text(size=14, face="bold")
  )

pie1 <- ggplot(df1,aes(x="",y=Num,fill=Type)) + geom_bar(width=1,stat="identity") + coord_polar("y",start=0) + blank_theme + theme(axis.text.x=element_blank()) + labs(title = "%s")
pie2 <- ggplot(df2,aes(x="",y=Num,fill=Type)) + geom_bar(width=1,stat="identity") + coord_polar("y",start=0) + blank_theme + theme(axis.text.x=element_blank()) + labs(title = "%s")

png(filename="%s",width=2400,height=800,units = "px",res=300)
vplayout <- function(x, y) viewport(layout.pos.row = x, layout.pos.col = y)
grid.newpage()
pushViewport(viewport(layout = grid.layout(1, 2)))
print(pie1, vp = vplayout(1, 1))
print(pie2, vp = vplayout(1, 2))
dev.off()

''' % (type_g,num_g,type_e,num_e,title1,title2,outpath)
    return script_str

def main():
    ifs=sys.stdin
    output=None
    #sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\HQG.annotation.txt','-m','1']
    opts=getopts()
    mode=3
    for key,value in opts:
        if key in ('-i'):
            input=value
            ifs=open(value,'r')
            continue
        if key in ('-o'):
            output=value
            continue
        if key in ('-m'):
            mode=value
            continue
        print 'Do not find option %s' %key
        sys.exit(2)
    if output==None:
        output=input+'.stat.region-func.png'
    list=[line.strip() for line in ifs]
    if mode=='1':
        type_g,num_g=prepareGenomeRegionData(list)
        script=drawSingleFigure(type_g,num_g,output,' ')
    elif mode=='2':
        type_e,num_e=prepareFunctionTypeInExomeData(list)
        script=drawSingleFigure(type_e,num_e,output,' ')
    elif mode=='3':
        type_g,num_g=prepareGenomeRegionData(list)
        type_e,num_e=prepareFunctionTypeInExomeData(list)
        script=drawTwoCharInOneFigure(type_g,num_g,type_e,num_e,output,'','')
    script_path='./.script.stat.tmp.R.sh'
    ofs=open(script_path,'w')
    ofs.write(script)
    ofs.flush()
    ofs.close() # fix bug: Text file busy
    os.system('chmod 755 '+script_path)
    os.system(script_path)
    os.system('rm '+ script_path)

if __name__=='__main__':
    main()

