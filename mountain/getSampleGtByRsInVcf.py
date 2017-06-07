# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create on: 20170606

'''


import sys
import getopt
import string

#sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\NA12878-3.pass.vcf','-f','C:\\Users\\Administrator\\Desktop\\trusigth_cardio_ref_freq.table','-o','C:\\Users\\Administrator\\Desktop\\fake.vcf']
try:
    opts, args = getopt.getopt(sys.argv[1:], "i:o:r:", [''])
except getopt.GetoptError:
    print '''
        program.py -i <INPUT.vcf> -o <OUTPUT.txt> -r <rs.list>
        rslist format rsID<TAB>Ref
    '''
    sys.exit(1)
input, output = None, None
rslist=[]
rsRefMap={}

for key, value in opts:
    if key in ('-i'):
        input = value
        continue
    if key in ('-o'):
        output = value
        continue
    if key in ('-r'):
        rsRefMap={line.strip().split('\t')[0]:line.strip().split('\t')[1] for line in open(value).readlines()}
        rslist=[line.strip().split('\t')[0] for line in open(value).readlines()]
if input:
    ifs=open(input,'r')
else:
    ifs=sys.stdin
if output:
    output=open(output,'w')
else:
    output=sys.stdout
vcfMap={}
rs_set=set(rslist)
for line in ifs:
    l = line.strip().split('\t')
    if line.startswith('#'):
        if line.startswith('#CHROM'):
            sample=l[9]
        continue
    ref=[l[3]]
    alt=l[4].split(',')
    ref.extend(alt)# 合并两个list
    gt=l[9].split(':',1)[0]
    if not l[2] in rs_set: continue
    vcfMap[l[2]]=''
    if '/' in gt:
	gt = gt.split('/')
    elif '|' in gt:
	gt = gt.split('|')
    for alttmp in gt:
        vcfMap[l[2]]=vcfMap[l[2]]+ref[string.atoi(alttmp)]
print '\n'+sample
for rs in rslist:
    if rs in vcfMap.keys():
        print rs+'\t'+vcfMap[rs]
    else:
        print rs + '\t' + rsRefMap[rs]


if output:
    output.flush()
    output.close()




