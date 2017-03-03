# -*- coding: utf-8 -*-
#! /usr/bin/python
# Create on: 20160325
# Modify on: 20160412
# Output option is a path prefix without suffix.
# Input option is a directory path

__author__ = 'Jason'

import getopt
import sys
import os


def getopts():
    try:
        options,args = getopt.getopt(sys.argv[1:],"d:o:",[''])
        return options
    except getopt.GetoptError:
        print '''
        program.py -d Directory -o Path.
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
        if '-' in t[3] or '-' in t[4]:  continue
        if len(t[3]) !=len(t[4]):         continue
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

def prepareFigure1Data(sampleList,data_map):
    temp_path=os.getcwd()+os.sep+'.figure.mutations'
    temp_file=open(temp_path,'w')
    temp_file.write('Name\tType\n')
    for sample in sampleList:
        for line in data_map[sample]:
            temp_file.write(sample+'\t'+line+'\n')
    temp_file.flush()
    temp_file.close()
    return temp_path

def prepareFigure2Data(sampleList,data_map):
    list=['C>T/G>A', 'T>C/A>G', 'C>G/G>C', 'C>A/G>T','T>G/A>C','T>A/A>T']
    temp_path=os.getcwd()+os.sep+'.figure.mutationsnum'
    temp_file=open(temp_path,'w')
    temp_file.write('Name')
    for e in list:
        temp_file.write('\t'+e)
    else:
        temp_file.write('\n')
    for sample in sampleList:
        map={
            'C>T/G>A':0,
            'T>C/A>G':0,
            'C>G/G>C':0,
            'C>A/G>T':0,
            'T>G/A>C':0,
            'T>A/A>T':0
        }
        sum=0
        for line in data_map[sample]:
            map[line]=map[line]+1
            sum=sum +1
        temp_file.write(sample)
        for e in list:
            temp_file.write('\t%.4f'%(float(map[e])/sum))
        else:
            temp_file.write('\n')
    temp_file.flush()
    temp_file.close()
    return temp_path

def drawFigure(path1,path2,out):
    print 'Draw figure'
    script_path=os.getcwd()+os.sep+'script_mutation.R.sh'
    script=open(script_path,'w')
    script.write('#! /usr/bin/Rscript\n')
    script.write('library(ggplot2)\nlibrary(pheatmap)\n')
    script.write('\ndata1<- read.table("%s",sep=\'\\t\',header=T,check=F)\n'%path1)
    script.write('f1<- ggplot(data = data1, aes(x = Name, fill = Type)) + geom_bar(position = "fill") + labs(title = "Mutation Spectrum",x = "",y = "Fraction of Mutations") + theme(panel.background = element_blank(), axis.text.x  = element_text(angle=90), text = element_text(size=16) ) \n')
    script.write('png(file="%s.fraction.png")\n'% out)
    script.write('f1\n')
    script.write('dev.off()\n')
    script.write('svg(file="%s.fraction.svg")\n'% out)
    script.write('f1\n')
    script.write('dev.off()\n')

    script.write('\ndata2<- read.csv("%s", sep="\\t",check=F)\n'% path2)
    script.write('row.names(data2) <- data2$Name\n')
    script.write('data2=data2[,2:7]\n')
    script.write('data2_matrix<- data.matrix(data2)\n')
    script.write('png(file="%s.heatmap.png")\n'% out)
    script.write('pheatmap(data2_matrix,fontsize=14,fontsize_row=12,cluster_rows=T,cluster_cols=F)\n')
    script.write('dev.off()\n')
#    do not support svg
#    script.write('svg(file="%s.heatmap.svg")\n'% out)
#    script.write('pheatmap(data2_matrix,fontsize=14,fontsize_row=12,cluster_rows=T,cluster_cols=F)\n')
#    script.write('dev.off()\n')
    script.flush()
    script.close()
    print 'clean'
    os.system('chmod 755 %s\n' % script_path)
    os.system('%s\n'%script_path)
    os.system('rm %s %s %s '%(path1,path2,script_path))


def main():
#    sys.argv=['','-d','C:\\Users\\Administrator\\Desktop\\test','-o','C:\\Users\\Administrator\\Desktop\\test.t']
    opts=getopts()
    input_dir,out_panth=None,None
    for key,value in opts:
        if key in ('-d'):
            input_dir=value
            continue
        if key in ('-o'):
            out_panth=value
            continue
    if input_dir==None or out_panth==None:
        print 'Please set input directory or out figure path'
        sys.exit()
    sampleList=[]
    raw_data={}
    print'Prepare raw data'
    for file in os.listdir(input_dir):
        if file.startswith('.'):
            continue
        sample_name=file.split('.')[0]
        if sample_name in sampleList:
            print 'repeat sample name %s' % sample_name
            sys.exit(1)
        else: sampleList.append(sample_name)
        result_list=prepareRawData('%s%s%s'%(input_dir,os.sep,file))
        raw_data[sample_name]=result_list
    path1=prepareFigure1Data(sampleList,raw_data)
    path2=prepareFigure2Data(sampleList,raw_data)
    drawFigure(path1,path2,out_panth)


if __name__=='__main__':
    main()

