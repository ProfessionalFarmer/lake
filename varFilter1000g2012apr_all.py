# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create   on: 20160125
Modified on: 20160304
'''
import getopt
import sys
import string

colName='1000g2012apr_all'
colEmpty='.'
cutoff=0.05

def getopts():
    try:
        options,args = getopt.getopt(sys.argv[1:],"i:o:c:",[''])
        return options
    except getopt.GetoptError:
        print '''
        program.py -i <INPUT> -o <OUTPUT> -c <CUTOFF>
        Support stdin and sdtout.
        '''
        sys.exit()

def filter(list):
    """
    Filter snp with frequency higher than cutoff
    :param list: raw data
    :return:
    """
    new=[]
    global cutoff
    for i,line in enumerate(list):
        t = line.strip().split('\t')
        if i == 0:
            index=t.index(colName)
            new.append(line)
            continue
        if t[index]==colEmpty:
            new.append(line)
            continue
        freq=string.atof(t[index])
        if freq>=cutoff:
            continue
        new.append(line)
    return new

def main():
    global cutoff
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
        if key in ('-c'):
            cutoff=float(value)
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
    sys.stderr.write('1000 genome frequency filter: filter out snp with frequency higher than %f\nTotal number: %d\nAfter filter: %d\n' % (cutoff,total,after))

    for line in list:
        ofs.write(line)
    ofs.flush()
    ofs.close()

if __name__=='__main__':
    main()

