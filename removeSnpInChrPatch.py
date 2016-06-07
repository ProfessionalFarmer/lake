# -*- coding: utf-8 -*-
#! /usr/bin/python
__author__ = 'Jason'
'''
Create   on: 20160215
Modified on:
Remove variant which in chromosome patch, E.g.: chrUn_gl000231, chr9_gl000198_random
'''

import getopt
import sys

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
    :param list: raw data
    :return:
    """
    chrList=['chrM']
    for i in range(1,23):
        chrList.append('chr%d'%i)
    chrList.extend(['chrX','chrY'])
    new=[]
    for line in list:
        if line.startswith('#'):
	    new.append(line)
	    continue
	if line.split('\t')[0] in chrList:
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
    list=filter(list)

    for line in list:
        ofs.write(line)
    ofs.flush()
    ofs.close()

if __name__=='__main__':
    main()


