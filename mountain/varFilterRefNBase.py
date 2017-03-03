# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create   on: 20160429
Modified on:
'''
import getopt
import sys


colName='Ref'
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
    Filter snp without rs identifier
    :param list: raw data
    :return:
    """
    new=[]
    for i,line in enumerate(list):
        t = line.strip().split('\t')
        if i == 0:
            index=t.index(colName)
            new.append(line)
            continue
        if 'N' in t[index]:
            continue
        else:
            new.append(line)
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
    sys.stderr.write('N base ref filter: filter snp that has a N base in ref.\nTotal number: %d\nAfter filter: %d\n' % (total,after))

    for line in list:
        ofs.write(line)
    ofs.flush()
    ofs.close()

if __name__=='__main__':
    main()


