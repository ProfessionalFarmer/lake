# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create on: 20170606

'''


import sys
import getopt

#sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\NA12878-3.pass.vcf','-f','C:\\Users\\Administrator\\Desktop\\trusigth_cardio_ref_freq.table','-o','C:\\Users\\Administrator\\Desktop\\fake.vcf']
try:
    opts, args = getopt.getopt(sys.argv[1:], "i:o:r:", [''])
except getopt.GetoptError:
    print '''
    program.py -i <INPUT.vcf> -o <OUTPUT.txt> -r <rs.list>
        '''
    sys.exit(1)
input,output=None,None
ifs, ofs = None, None
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
        rslist=[line.strip() for line in open(value).readlines()]
if input:
    ifs=open(input,'r')
else:
    ifs=sys.stdin
if output:
    ofs=open(output,'w')
else:
    ofs=sys.stdout

rsRefBaseMap={}
rs_set=set(rslist)
for line in ifs:
    if line.startswith('#'): continue
    l=line.split('\t')
    if not l[2] in rs_set: continue
    rsRefBaseMap[l[2]]='\t'.join(l[:4])
for rs in rslist:
    ofs.write(rs+'\t'+rsRefBaseMap[rs]+'\n')


ofs.flush()
ofs.close()




