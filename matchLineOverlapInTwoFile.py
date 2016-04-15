# -*- coding: utf-8 -*-
#! /usr/bin/python

__author__ = 'Jason'
'''
Ouput overlap line or not overlap line.
This script consider whole line, not part fields of line
f: first file path
s: second file path
t: -t output non-overlap line that the line in first file and not in second file
Create   on: 20160412
Modified on:
'''

import getopt
import sys

def main():
    options,args = getopt.getopt(sys.argv[1:],"f:s:t",[''])
    first_file,second_file,non_overlap=None,None,False
    for key,value in options:
        if key in ('-f'):
            first_file=value
            continue
        if key in ('-s'):
            second_file=value
            continue
        if key in ('-t'):
            non_overlap=True
            continue    
    if first_file==None or second_file==None:
        sys.stderr.write('Please input file path')
        sys.exit()
    second_set=set() 
    sys.stderr.write('\n####    ####') 
    for line in open(second_file):
	line=line.strip()
	second_set.add(line)
    sys.stderr.write('\n####    ####\n%s  Non-repeat line number:\n%.0f\n'%(second_file,len(second_set)))
    i,j=0,0
    for line in open(first_file):
	i=i+1
        line=line.strip()
	if line in second_set:
	    if not non_overlap:
		print line
		j=j+1
	else:
	    if non_overlap:
		print line
		j=j+1
    sys.stderr.write('%s line number: %.0f\n'%(first_file,i))
    sys.stderr.write('Search overlap: %s\nResult line number: %.0f\n\n'%(str(not non_overlap),j))
    sys.stderr.flush()
    sys.stderr.close()

if __name__=='__main__':
    main()
