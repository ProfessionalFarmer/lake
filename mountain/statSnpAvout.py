# -*- coding: utf-8 -*-
#! /usr/bin/python
__author__ = 'Jason'
# Create: 20160119
# Modified on: 20160115, 20160229
# Statistic snp annotated by annovar
# Support csv and tab format
# Use stdout if output file not specified
# Further should support hom/het, ts/tv and novel ts/tv 


from optparse import OptionParser
import sys
import os
import csv

altColName='Alt'
refColName='Ref'
dbsnpColName='avsnp142'
colEmpty='.'
regionColName='Func.refGene'
funcColName='ExonicFunc.refGene'
zygosityColName='zyg'
tgColName='1000g2014oct_all'


def getOptions():
    parser = OptionParser(usage="%prog -i <INPUT> [-O <OUTPUT>] <--snp|--indel>", version="%prog 1.0")
    parser.add_option("-i",     "--input",     type="string",   dest="input",   action="store",      help="Input file. File should be seperated by tab or comma. Input file is required.", metavar="FILE")
    parser.add_option("-o",     "--output",    type="string",   dest="output",  action="store",      help="Output file path. If not specify, use stdout.", metavar="FILE")
    parser.add_option("-t",     "--tab",       default=True,      dest="tab",     action="store_true", help="Line field is tab splitted. Default True." )
    parser.add_option("-c",     "--csv",       default=False,     dest="csv",     action="store_true", help="Line field is ',' splitted.")
    parser.add_option("-s",     "--sample",    dest="sample",   action="store", help="Sample name",metavar="NAME")
    parser.add_option("",     "--indel",       default=False,   dest="indel",   action="store_true", help="Stat indel. Default false.")
    parser.add_option("",     "--snp",         default=False,    dest="snp",   action="store_true", help="Stat snp. Default false.")
    (options, args) = parser.parse_args()
    return options

def readFileTab(path):
    list=[]
    list=[line.strip().split('\t') for line in open(path,'r').readlines()]
    return list

def readFileCSV(path):
    with open(path, 'rb') as csvfile:
        spamreader = csv.reader(csvfile)
        list=[]
        list=[row for row in spamreader]
        return list

def isIndel(line_arrary):
    if len(line_arrary[3])!=len(line_arrary[4]) or (line_arrary[3]+line_arrary[4]).find('-')!=-1:
        return True
    else: return False

def statNovel(list):
    count_snp_novel=0
    count_snp_known=0
    count_indel_novel=0
    count_indel_known=0
    for i,line in enumerate(list):
        if i==0:
            if dbsnpColName not in line:
                return ''
            dbsnpi=line.index(dbsnpColName)
            continue
        rs=line[dbsnpi]
        if rs==colEmpty:
            if isIndel(line):
                count_indel_novel=count_indel_novel+1
            else:
                count_snp_novel=count_snp_novel+1
        elif 'rs' in rs:
            if isIndel(line):
                count_indel_known=count_indel_known+1
            else:
                count_snp_known=count_snp_known+1
        else:
            print 'Error for: %s' % line
    if count_snp_known==0 and count_snp_novel==0 and count_indel_novel==0 and count_indel_known==0:
        return ''
    else:
        s = '[Known/Novel in dbSNP]\n## = Total (SNP/Indel)\nNovel = %d (%d/%d)\nKnown = %d (%d/%d)\n\n'% (count_snp_novel+count_indel_novel,count_snp_novel, count_indel_novel,count_snp_known+count_indel_known,count_snp_known,count_indel_known)
        return s

def statRegionAnn(list):
    map={}
    for i,line in enumerate(list):
        if i==0:
            if regionColName not in line:
                return ''
            regioni=line.index(regionColName)
            continue
        type=line[regioni]
        if map.has_key(type):
            if isIndel(line):
                map[type][1]+=1
            else:
                map[type][0]+=1
        else:
            if isIndel(line):
                map[type]=[0,1]
            else:
                map[type]=[1,0]
    if map=={}:return ''
    s='[Region-based Annotation]\n## = Total (SNP/Indel)\n'
    for key,value in map.items():
        s=s+'%s = %d (%d/%d)\n'%(key,value[0]+value[1],value[0],value[1])
    s=s+'\n'
    return s

def statExonicFunc(list):
    map={}
    for i,line in enumerate(list):
        if i==0:
            if funcColName not in line:
                return ''
            funcColNamei=line.index(funcColName)
            continue
        type=line[funcColNamei]
        if type == colEmpty: continue
        if map.has_key(type):
            if isIndel(line):
                map[type][1]+=1
            else:
                map[type][0]+=1
        else:
            if isIndel(line):
                map[type]=[0,1]
            else:
                map[type]=[1,0]
    if map=={}:return ''
    s='[Exonic Function Annotation]\n## = Total (SNP/Indel)\n'
    for key,value in map.items():
        s=s+'%s = %d (%d/%d)\n'%(key,value[0]+value[1],value[0],value[1])
    s=s+'\n'
    return s

def statHetero(list):
    count_snp_het=0
    count_snp_hom=0
    count_indel_het=0
    count_indel_hom=0
    for i,line in enumerate(list):
        if i==0:
            if zygosityColName not in line:
                return ''
            zygColNamei=line.index(zygosityColName)
            continue
        if 'hom' in line or 'hom\n' in line[zygColNamei] :
            if isIndel(line):
                count_indel_hom+=1
            else:
                count_snp_hom+=1
            continue
        if 'het' in line or 'het\n' in line[zygColNamei] :
            if isIndel(line):
                count_indel_het+=1
            else:
                count_snp_het+=1
            continue
    if count_snp_het==0 and count_snp_hom==0 and count_indel_het==0 and count_indel_hom==0:
        return ''
    else:
        s = '[Heterozygous(Hom/Het)]\n## = Total (SNP/Indel)\nHomozygous = %d (%d/%d)\nHeterozygous = %d (%d/%d)\n'% (count_snp_hom+count_indel_hom, count_snp_hom,count_indel_hom,count_snp_het+count_indel_het,count_snp_het,count_indel_het)
        return s

def statIn1000Genome(list):
    count_snp_intg=0
    count_snp_nointg=0
    count_indel_intg=0
    count_indel_nointg=0
    for i,line in enumerate(list):
        if i==0:
            if tgColName not in line:
                return ''
            tgColNamei=line.index(tgColName)
            continue
        value=line[tgColNamei]
        if value==colEmpty:
            if isIndel(line):
                count_indel_intg+=1
            else:
                count_snp_intg+=1
        else:
            if isIndel(line):
                count_indel_nointg+=1
            else:
                count_snp_nointg+=1
    if count_snp_intg==0 and count_indel_intg==0 and count_snp_nointg==0 and count_indel_nointg==0:
        return ''
    else:
        s = '[Summary in 1000 genome]\n## = Total (SNP/Indel)\nIn 1000 genome = %d (%d/%d)\n\n' % (count_snp_intg+count_indel_intg,count_snp_intg,count_indel_intg)
        return s


def main():
    #sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\sample1.out.txt','--snp','--indel']
    options=getOptions()
    if options.input: # check input
        if not os.path.isfile(options.input):
            print 'input file does not exist.'
            sys.exit(1)
    else:
        print 'Please set input file'
        sys.exit(1)

    if not (options.snp or options.indel):
        print 'Please set which kind variant you want to statistic. --snp or --indel'
        sys.exit(1)
    if options.csv:
        list=readFileCSV(options.input)
    else:
        list=readFileTab(options.input)
    newList=[]
    snp_count,indel_count=0,0
    for i,line in enumerate(list): ## filter snp or indel
        if i==0:
            newList.append(line)
            refi=line.index(refColName)
            alti=line.index(altColName)
            continue
        ref=line[refi]
        alt=line[alti]
        seq=ref+alt
        n=seq.find('-') #-1: not indel
        if len(alt)!=len(ref) or n!=-1:
            n=1000
            if options.indel: indel_count=indel_count+1
        else:
            if options.snp: snp_count=snp_count+1
        if not options.snp and n==-1:
            continue
        if not options.indel and n!=-1:
            continue
        newList.append(line)
    list=newList

    if options.output:
        out=open(options.output,'w')
    else: out=sys.stdout # if output path not specified, use stdout instead

    if not (list[0][0]=='Chr' and list[0][1]=='Start' ): ## check header
        print 'Do not find header in file. Chr	Start	End'
        sys.exit(1)
    if not options.sample: # if sample name not set
        options.sample=options.input
    out.write('[General]\nSample = '+options.sample+'\nSNP = '+str(options.snp)+'\nIndel = '+str(options.indel)+'\n')
    out.write('SNP_count = %d\nIndel_count = %d\n'%(snp_count,indel_count))
    out.write('Total = %s\n\n' % str(len(newList)-1))
    out.write(statNovel(list))
    out.write(statRegionAnn(list))
    out.write(statExonicFunc(list))
    out.write(statHetero(list))
    out.write(statIn1000Genome(list))
    out.flush()
    out.close()

if __name__=='__main__':
    main()






