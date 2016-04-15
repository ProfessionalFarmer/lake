# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create   on: 20160304
Modified on:
User can specify which columns to compare and which columns to output.
Support stdout, not support std in
If no header in file, please set --ignoreHeader option.
Sample file example:
SampleName\tSampleFilePath
'''
from optparse import OptionParser
import sys


def getOptions():
    parser = OptionParser(usage="%prog -i <SAMPLE_FILE> [-O <OUTPUT>] [--ignoreHeader] [--outCol=1,2,3,4] [--targetCol=1,2,3,4,5]", version="%prog 1.0")
    parser.add_option("-i",   "--input",       type="string",   dest="input",   action="store",    help="Input file. 'sampleName\tsampleFilePath' per line", metavar="FILE")
    parser.add_option("",     "--targetCol",   type="string",   dest="target",  action="store",   help="Specify which columns to compare",           metavar="String", default='1,2,3,4,5')
    parser.add_option("-o",   "--output",      type="string",   dest="output",  action="store",     help="Output file path. If not specify, use stdout.", metavar="FILE")
    parser.add_option("",     "--outCol",      type="string",   dest="outcol",  action="store",     help="Specify which columns to output. Default output whole line.", metavar="String")
    parser.add_option("",     "--ignoreHeader", default=True,   dest="header",   action="store_false", help="If ignore header. Default True.")
    (options, args) = parser.parse_args()
    return options

def readFile(path,cols,ignoreHeader=True):
    list=[line.strip() for line in open(path)]
    colList=[int(col) for col in cols.split(',')]
    map={}
    header=''
    for i,line in enumerate(list):
        if i==0 and ignoreHeader:
            header=line
            continue
        else:
            t=line.split('\t')
            key_temp=''
            for col in colList:
                key_temp=key_temp+t[col-1]
            map[key_temp]=line
    return map,header

def countFrequency(sampleList,sampleMap):
    result_map={}
    sampleNumber=len(sampleList)
    for i,sampleName in enumerate(sampleList):
        current_sample=sampleMap[sampleName]
        for key in current_sample:
            key_freq=1
            appear_sample=sampleName
            for j in range(i+1,sampleNumber):
                if key in sampleMap[sampleList[j]]:
                    key_freq+=1
                    appear_sample=appear_sample+', '+sampleList[j]
                    del sampleMap[sampleList[j]][key]
            result_map[current_sample[key]]='%d\t%s'%(key_freq,appear_sample)
    return  result_map


def main():
    #sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\sampleFile.txt','--outCol=1,2,3']
    opts=getOptions()
    input=None
    ifs,ofs=None,None
    if not opts.input:
        print 'Please set input sample path.'
        exit(1)
    else:
        input=opts.input
        ifs=open(input,'r')
    if opts.output:
        ofs=open(opts.output,'w')
    else: ofs=sys.stdout

    sampleList=[]
    sampleMap={}
    for line in ifs:
        if '\t' in line:
           t=line.strip().split('\t')
        else:
            sys.stderr.write('Please use TBA to seperate')
        if len(t)<2:
            sys.stderr.write('Error in sample file: %s' % line)
        sampleList.append(t[0])
        targetMap=None
        targetMap,header=readFile(t[1],opts.target,ignoreHeader=opts.header)
        sampleMap[t[0]]=targetMap
    result_map=countFrequency(sampleList,sampleMap)
    if opts.header:
        ofs.write('Frequency\tSamples\t'+header+'\n')
    for key,value in result_map.items():
        out_col_content=''
        if not opts.outcol:
            out_col_content=key
        else:
            colList=[int(col) for col in opts.outcol.split(',')]
            for col in colList:
                out_col_content=out_col_content+key.split('\t')[col-1]+'\t'
            out_col_content=out_col_content.strip()
        ofs.write('%s\t%s\n' % (value,out_col_content))

    ofs.flush()
    ofs.close()

if __name__=='__main__':
    main()




