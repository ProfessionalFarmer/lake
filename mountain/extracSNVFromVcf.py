# -*- coding: utf-8 -*-
#! /usr/bin/python
# Create on: 20160325
# Modify on:
__author__ = 'Jason'


import getopt
import sys



def getopts():
    try:
        options,args = getopt.getopt(sys.argv[1:],"i:o:",[''])
        return options
    except getopt.GetoptError:
        print '''
        program.py -i input -o output
        support stdin and stdout
        '''
        sys.exit()

def main():
  #  sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\README.txt']
    opts=getopts()
    input,output=None,None
    ifs,ofs=sys.stdin,sys.stdout
    for key,value in opts:
        if key in ('-i'):
            input=value
            ifs=open(input,'r')
            continue
        if key in ('-o'):
            output=value
            ofs=open(output,'w')
            continue
        if key in ('-c'):
            cutoff=float(value)
            continue
    for line in ifs:
        if line.startswith('#'):
            ofs.write(line)
            continue
        if len(line.split('\t')[3])!=1 or len(line.split('\t')[4])!=1:
            continue
        else: ofs.write(line)
    ofs.flush()
    ofs.close()


if __name__=='__main__':
    main()

