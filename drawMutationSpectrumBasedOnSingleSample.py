# -*- coding: utf-8 -*-
#! /usr/bin/python
# Create on: 20160413
# Modify on:
__author__ = 'Jason'

import getopt
import sys
import os


def getopts():
    try:
        options,args = getopt.getopt(sys.argv[1:],"i:o:",[''])
        return options
    except getopt.GetoptError:
        print '''
        Just draw base change type based on single sample vcf or annovar file.
        program.py -i InputFile -o Path.
        '''
        sys.exit()

def prepareRawData(path):
    input=open(path,'r')
    result_list=[]
    for line in input:
        if line.startswith('#'): continue
        t=line.split('\t')
        if t[0]=='Chr':
            continue
        if '-' in t[3] or '-' in t[4]:   result_list.append('InDel')
        if len(t[3]) !=len(t[4]):        result_list.append('InDel')
        ref=t[3]
        alt=t[4]
        if (ref=='C' and alt=='T') or (ref=='G' and alt=='A') :
            result_list.append('C>T/G>A')
            continue
        if (ref=='T' and alt=='C') or (ref=='A' and alt=='G') :
            result_list.append('T>C/A>G')
            continue
        if (ref=='C' and alt=='G') or (ref=='G' and alt=='C') :
            result_list.append('C>G/G>C')
            continue
        if (ref=='C' and alt=='A') or (ref=='G' and alt=='T') :
            result_list.append('C>A/G>T')
            continue
        if (ref=='T' and alt=='G') or (ref=='A' and alt=='C') :
            result_list.append('T>G/A>C')
            continue
        if (ref=='T' and alt=='A') or (ref=='A' and alt=='T') :
            result_list.append('T>A/A>T')
            continue
    input.close()
    return result_list

def prepareFigure1Data(list):
    temp_path=os.getcwd()+os.sep+'.figure.mutations'
    temp_file=open(temp_path,'w')
    temp_file.write('Type\n')
    for e in list:
        temp_file.write(e+'\n')
    temp_file.flush()
    temp_file.close()
    return temp_path


def drawFigure(path1,out):
    print 'Draw figure'
    script_path=os.getcwd()+os.sep+'script_mutation.R.sh'
    script=open(script_path,'w')
    script.write('''#! /usr/bin/Rscript
library(ggplot2)
data <- read.table("%s",sep="\t",header=T,check=F)
## skip
## bg <- ggplot(data = data, aes(x = Name, fill = Type)) + geom_bar(position = "fill") + labs(title = "Mutation Spectrum",x = "",y = "Fraction of Mutations") + theme(panel.background = element_blank(), axis.text.x  = element_text(angle=90), text = element_text(size=16) ) 
##png(file="path.fraction.png",width=800,height=600,res=400)
##
bg <- ggplot(data = data, aes(x = Type)) + geom_bar()
png(file="%s.fraction.png")
bg
dev.off()
svg(file="%s.fraction.svg")
bg
dev.off()
\n'''%(path1,out,out))
    print 'clean'
    os.system('chmod 755 %s\n' % script_path)
    os.system('%s\n'%script_path)
    os.system('rm %s %s '%(path1,script_path))


def main():
#    sys.argv=['','-d','C:\\Users\\Administrator\\Desktop\\test','-o','C:\\Users\\Administrator\\Desktop\\test.t']
    opts=getopts()
    input_file_path,out_panth=None,None
    for key,value in opts:
        if key in ('-i'):
            input_file_path=value
            continue
        if key in ('-o'):
            out_path=value
            continue
    if input_file_path==None or out_path==None:
        print 'Please set input file path or out figure path'
        sys.exit()
    print'Prepare raw data'
    result_list=prepareRawData(input_file_path)
    path1=prepareFigure1Data(result_list)
    drawFigure(path1,out_path)

if __name__=='__main__':
    main()


