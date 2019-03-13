# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create on: 20170606

'''

import sys
import getopt

#sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\NA12878-3.pass.vcf','-f','C:\\Users\\Administrator\\Desktop\\trusigth_cardio_ref_freq.table','-o','C:\\Users\\Administrator\\Desktop\\fake.vcf']
try:
    opts, args = getopt.getopt(sys.argv[1:], "i:o:s:e", [''])
except getopt.GetoptError:
    print '''
    program.py -i <INPUT.vcf> -o <OUTPUT.txt> -s <sample> [-e] 
        '''
    sys.exit(1)
input, output = None, None
ifs, ofs = None, None
sample=''
exclude_ref=False
for key, value in opts:
    if key in ('-i'):
        input = value
        continue
    if key in ('-o'):
        output = value
        continue
    if key in ('-s'):
        sample=value
        continue
    if key in ('-e'):
	exclude_ref=True
	continue
if input:
    ifs=open(input,'r')
else:
    ifs=sys.stdin
if output:
    ofs=open(output,'w')
else:
    ofs=sys.stdout
for line in ifs:
    l=line.strip().split('\t')
    if line.startswith('#'):
        if line.startswith('#CHR'):
            i=l.index(sample)
            basic=l[:9]
	    basic.append(l[i])
            ofs.write('\t'.join(basic)+'\n')
        else:
            ofs.write(line)
        continue
    basic=l[:9]
    basic.append(l[i])
    if exclude_ref and  ( '0|0' in line or '0/0' in line) : continue
    ofs.write('\t'.join(basic)+'\n')
if output:
    output.flush()
    output.close()

