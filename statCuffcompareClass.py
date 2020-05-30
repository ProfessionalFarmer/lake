# -*- coding: utf-8 -*-
#######################################################################################
###                                                                                 ###
###     Stat class code from cuffcompare result: from tracking file (just stat j and =)
###     Copyright (C) 2020  Zhongxu ZHU, CityU, 20200530                            ###
#######################################################################################
#
# Output:
# DDX3Y   TCONS_00061044  =       CRC010N.2880


__author__ = 'Jason'


import sys
import argparse

# sys.argv = ["","-i","c99i95refMin2/gff/s2.tracking","-o","c99i95refMin2/gff/class.stat"]


parser = argparse.ArgumentParser(description='Process description',prog='PROG', usage='%(prog)s [options]')
parser.add_argument('-i',metavar='File path',action = 'store',type = str ,dest = 'input',
                     default='',help="Gffcompare tracking format", required=True)
parser.add_argument('-o',metavar='Output File',action = 'store',type = str ,dest = 'output',
                     default='',help="Output file path", required=False)
                     
args = parser.parse_args()


outs = ''
if not args.output :
    outs = sys.stdout
else:
    outs = open(args.output,'w')
    
# # because we ignore contained transcript, so merged transcripts are not equle to all single sample transcript. To solve this, we scan all transcript in merged.gtf first.

# total transcript
transcriptInMergedGtf = set()

for line in open(args.input.replace("tracking","combined.gtf")):
    line = line.strip()
    if line.startswith('#'): continue
    infoField = line.split('\t')[8]
    infoMap = {}
    for field in infoField.split(";"):
        if field == "": continue
        field = field.strip(" ")
        infoMap[field.split(' ')[0]] = field.split(' ')[1].strip("\"")
    transcriptInMergedGtf.add(infoMap["transcript_id"])
    
    
# 需要注意的是前期处理的时候，基因都替换成了样本+id，所以在tracking文件中的gene位置显示的是样本，这样便于统计样本
outs.write("Gene\tTracking\tClass\tSample\n")
for line in open(args.input):
    llist = line.strip().split('\t')
    trackingid = llist[0]
    if not trackingid in transcriptInMergedGtf: continue
    gene = llist[2].split('|')[0]
    classcode = llist[3]
    if not classcode == '=' and not classcode == 'j': continue ## filter none j and none =
    transcript = llist[2].split('|')[1]

    count = 0
    if classcode == '=': count = 100
    for sampleinfo in llist[4:len(llist)]:
        if sampleinfo != '-': count = count + 1

    if count <=1 : continue  ## filter

    for sampleinfo in llist[4:len(llist)]:
        if sampleinfo == '-': continue
        sample = sampleinfo.split(':')[1].split('|')[0]
        outs.write("%s\t%s\t%s\t%s\n"%(gene, trackingid, classcode, sample))
outs.close()

