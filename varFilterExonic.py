# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create   on: 20160125
Modified on: 20160304
'''
import getopt
import sys


colName='Func.refGene'
colEmpty='.'

def getopts():
    try:
        options,args = getopt.getopt(sys.argv[1:],"i:o:",[''])
        return options
    except getopt.GetoptError:
        print '''
        program.py -i <INPUT> -o <OUTPUT>
        Support stdin and sdtout.
        '''
        sys.exit()

def filter(list):
    """
    Filter snp out of exonic region
    :param list: raw data
    :return:
    """
    new=[]
    cdsRegion=('exonic','splicing')
    for i,line in enumerate(list):
        t = line.strip().split('\t')
        if i == 0:
            index=t.index(colName)
            new.append(line)
            continue
        if t[index]==colEmpty:
            new.append(line)
            continue
	if t[index]=='ncRNA_exonic':
	    continue
        for e in cdsRegion:
            if e in t[index]:
                new.append(line)
                break
    return new

def main():
    #sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\CHG004881_CHG004880.germlineSNV.ann']
    opts=getopts()
    input,output=None,None
    ifs,ofs=None,None
    for key,value in opts:
        if key in ('-i'):
            input=value
            continue
        if key in ('-o'):
            output=value
            continue
    if input:
        ifs=open(input,'r')
    else:
        ifs=sys.stdin
    if output:
        ofs=open(output,'w')
    else:
        ofs=sys.stdout
    list=[line for line in ifs.readlines()]
    total=len(list)-1
    list=filter(list)
    after=len(list)-1
    sys.stderr.write('Exonic region filter: filter snp out of exon region (exonic and splicing)\nTotal number: %d\nAfter filter: %d\n' % (total,after))

    for line in list:
        ofs.write(line)
    ofs.flush()
    ofs.close()

if __name__=='__main__':
    main()

