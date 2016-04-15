__author__ = 'Jason'
'''
Time: 20160105
'''
# -*- coding: utf-8 -*-
import  getopt
import os
import sys
import string
fileSep='\t'
colEmpty='NA'
regionAnnColName='Func.refGene'
tgAnnColName='1000g2012apr_all'
espColName='esp6500si_all'
siftColName='avsift'
polyphen2ColName='LJB_PolyPhen2'


def getopts():
    try:
        options,args = getopt.getopt(sys.argv[1:],"i:o:s:",[''])
        return options
    except getopt.GetoptError:
        print '''
        program.py -i <INPUT> -o <OUTPUT> [-s STRATEGY]
        '''
        sys.exit()

def filterNoneCDS(list):
    newList=[]
    header=list.pop(0)
    newList.append(header)
    cdsRegion=('exonic','splicing')
    rcol=header.split(fileSep).index(regionAnnColName)
    for line in list:
        t=line.split(fileSep)
        if t[rcol]==colEmpty:
	    newList.append(line)
	    continue
        for e in cdsRegion:
	    if e in t[rcol]:
		newList.append(line)
		break
    print 'filter none cds: %d' % (len(newList)-1)
    return newList

def filterDbSNP(list):
    newList=[]
    for line in list:
	if fileSep+'rs' in line:
	    continue
	else:
            newList.append(line)
    print 'filter dbsnp: %d' % (len(newList)-1)
    return newList

def filterHigh1000GFreq(list):
    newList=[]
    freqCol=list[0].split(fileSep).index(tgAnnColName)
    for line in list:
	t=line.split(fileSep)
	if t[freqCol]==colEmpty:
	    newList.append(line)
	    continue
	if '.' in t[freqCol]:
	    freq=string.atof(t[freqCol])
	    if freq>=0.05:
		continue
	newList.append(line)
    print 'filter 1000G: %d' % (len(newList)-1)
    return newList

def filterHighEspFreq(list):
    newList=[]
    freqCol=list[0].split(fileSep).index(espColName)
    for line in list:
        t=line.split(fileSep)
        if t[freqCol]==colEmpty:
            newList.append(line)
            continue
        if '.' in t[freqCol]:
            freq=string.atof(t[freqCol])
            if freq>=0.05:
                continue
        newList.append(line)
    print 'filter ESP: %d' % (len(newList)-1)
    return newList

def filterSift(list):
    newList=[]
    freqCol=list[0].split(fileSep).index(siftColName)
    for line in list:
        t=line.split(fileSep)
        if t[freqCol]==colEmpty:
            newList.append(line)
            continue
        if '.' in t[freqCol]:
            freq=string.atof(t[freqCol])
            if freq>=0.05:
                continue
        newList.append(line)
    print 'filter SIFT: %d' % (len(newList)-1)
    return newList

def filterPolyphen2(list):
    newList=[]
    freqCol=list[0].split(fileSep).index(polyphen2ColName)
    for line in list:
        t=line.split(fileSep)
        if t[freqCol]==colEmpty:
            newList.append(line)
            continue
        if '.' in t[freqCol] or '1' in t[freqCol]:
            freq=string.atof(t[freqCol])
            if freq<0.95:
                continue
        newList.append(line)
    print 'filter Polyphen2: %d' % (len(newList)-1)
    return newList

def filterNoneCosmic(list):
	print 1


def main():
    #sys.argv=['','-i','./02.SNPs/HQG.snp.xls','-o','./HQG.snp.filter.txt']

    strategy='cdtesp'
    options=getopts()
    for key,value in options:
        if key in ('-i'):
            input=value
	    print 'Input: ' +input
            continue
        if key in ('-o'):
            output=value
	    continue
	if key in ('-s'):
	    strategy=value
	    continue
    ifs=open(input,'r')
    list=[]
    for line in ifs:
        list.append(line)
    ifs.close()
    print 'Total variants: %d' % (len(list)-1)
    for e in strategy:
    	if 'c' == e:
            list=filterNoneCDS(list)
    	if 'd' == e:
            list=filterDbSNP(list)
    	if 't' == e:
	    list=filterHigh1000GFreq(list)
    	if 'e' == e:
	    list=filterHighEspFreq(list)
    	if 's' == e:
	    list=filterSift(list)
        if 'p' == e:
      	    list=filterPolyphen2(list)
	if 'm' == e:
	    list=filterNoneCosmic(list)
    ofs=open(output,'w')
    for line in list:
	ofs.write(line)
    ofs.close()
    print 'Done\nOut: '+output


if __name__ == '__main__':
    main()
