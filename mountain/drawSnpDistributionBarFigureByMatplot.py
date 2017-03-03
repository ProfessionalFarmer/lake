#! /usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'Jason'
# Create: 20160120
# Modified on:
# Draw snp distribution figure per chr
# Input file should be from BEDtools map toolkit
# This script draw bar figure especially for exome sequencing

from optparse import OptionParser
import sys
import os
import string


def getOptions():
    parser = OptionParser(usage="%prog <-i INPUT -d OUTDIR>", version="%prog 1.0")
    parser.add_option("-i",     "--input",  type="string",   dest="input",  action="store",   help="Input file. File should be generated from BEDtools map toolkit. Required Option.", metavar="FILE")
    parser.add_option("-d",     "--dir",    type="string",   dest="dir",     action="store",   help="Output diretory. Required Option.", metavar="DIR")
    parser.add_option("-l",     "--length", type="int",default=100000, dest="length",  action="store",   help="Window size. Default 100000. Please make sure this value is corresponded with your data", metavar="INT")
    (options, args) = parser.parse_args()
    return options

def drawBarFig(chr,datalist):
    print '%s, ' % chr,
    global opt
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    fig=plt.style.use('ggplot')
    fig, (ax) = plt.subplots(nrows=1,figsize=(16,7))
    plt.rcParams['font.size'] = 12.0
    bin=range(1,len(datalist)+1)
    ticks=range(1,len(datalist)+1,100)
    rects1 = ax.bar(bin,datalist,width=2,color='blue',edgecolor = "none")## linewidth=0 can also control bar edge
    ax.set_ylabel("Number")
    ax.set_xlabel('Chromosome %s (%d bp per window, %d windows)' % (chr,opt.length,len(datalist)))
    fig.tight_layout()
    plt.savefig(opt.dir+os.sep+chr+'.number-distribution-by-window.png',dpi = 800,format='png',transparent=True)
    plt.close()

def process(list):
    print 'Draw figur: ',
    last=None # this is a buffer keeping the last unprocessed chr
    chrmap={}
    numlist=[]
    for line in list:
        t=line.split('\t')
        chr=t[0]
        num=string.atoi(t[3])
        if not last: ##first line
            last=chr
            numlist.append(num)
            continue
        if last!=chr: ## another chr
            drawBarFig(last,numlist)
            numlist=[]
            last=chr
            numlist.append(num)
        else: # same chr
            numlist.append(num)
    else:
        drawBarFig(last,numlist)
        numlist=[]



def main():
    global  opt
    opt=getOptions()
    if not (opt.input and opt.dir):
        print 'Please set input file (-i option) or output directory (-d option) '
        sys.exit(1)
    if os.path.isfile(opt.dir):
        print '%s is a file not directory, please set correctly.' % opt.dir
        sys.exit(1)
    if not os.path.exists(opt.dir):
        os.mkdir(opt.dir)
    linelist=[line for line in open(opt.input,'r').readlines() if 'chrM' not in line]
    process(linelist)


if __name__=='__main__':
    #sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\CHG004881_CHG004880.snp.distribution.txt','-d','C:\\Users\\Administrator\\Desktop\\figuretest']
    main()
