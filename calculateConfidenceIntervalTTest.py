# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create on: 20170413

'''

from scipy import stats
import numpy as np
import sys
import getopt
import string
import math

def main():
    sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\ha.txt']
    try:
        opts, args = getopt.getopt(sys.argv[1:], "i:o:", [''])
    except getopt.GetoptError:
        print '''
        Item\tvsample1_val\tsample2_val\tsample3_val\tsample4_val\n
        program.py -i <INPUT.txt> -o <OUTPUT.txt> -c <Confidence>
        '''
        sys.exit(1)
    confidence=0.95
    input,output=None,None
    for key,value in opts:
        if key in ('-i'):
            input=value
            continue
        if key in ('-o'):
            output=value
            continue
        if key in ('-c'):
            confidence=string.atof(value)
    if input:
        ifs=open(input,'r')
    else:
        ifs=sys.stdin
    if output:
        output=open(output,'w')
    else:
        output=sys.stdout
    output.write('Name\tMean\tSTD\tCI ('+str(confidence)+')\n')
    for line in ifs:
        line=line.strip()
        llist=line.split('\t')
        item=llist[0]

        a=np.array(llist[1:])
        a=[string.atof(element) for element in a]
        mean,sigma=np.mean(a), np.std(a)
        conf_int = stats.norm.interval(confidence, loc=mean, scale=sigma/math.sqrt(len(a)))

        if sigma==0:
            output.write('%s\t%.4f\t%.4f\t(100 - 100)\n' % (item, mean, sigma))
        else:
            output.write('%s\t%.4f\t%.4f\t(%.4f - %.4f)\n'%(item,mean,sigma,conf_int[0],conf_int[1]))


if __name__=='__main__':
    main()




