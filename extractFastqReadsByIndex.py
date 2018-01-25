# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create on: 2018-01-25
------------------
根据index，从fastq文件中提取reads
需要输入INDEX或者barcode的正则表达式
------------------

'''

import sys
import getopt
import gzip
import re


def check_index(i7,i5,read_name):
    idx=read_name.split(' ')[1].split(':')[3]# E.G.   @M04988:24:000000000-G1H2R:1:1101:15824:1351 1:N:0:NNTGNTGT+TATTTTGT
    #print re.search(i7+i5,idx)
    an = re.search(i7+'\+'+i5,idx)
    if an :  return True
    else :   return False

def main():
    #sys.argv=['','-i','C:\\Users\\T3\\Desktop\\Undetermined_S0_L001_R1_001.fastq.gz','-7','CGTGAT\w\w','-5','TATCCT\w\w']
    try:
        opts, args = getopt.getopt(sys.argv[1:], "i:g:7:5:", [''])
    except getopt.GetoptError:
        print '''
        program.py -i inputFile -7 i7Pattern -5 i5Pattern
        '''
        sys.exit(1)
    i7,i5='',''
    ifs=sys.stdin
    input_file=''
    for key, value in opts:
        if key=='-i': #
            input_file=value
        if key=='-7':
            i7=value
        if key=='-5':
            i5=value
    if i5=='' or i7=='':
        sys.stderr.write('Please set i7 or i5 pattern')
        sys.exit(1)
    if input_file.endswith('gz'):
        ifs=gzip.open(input_file, "rb")
    elif input_file.endswith('fastq'):
        ifs=open(input_file,'r')
    elif input_file.endswith('fq'):
        ifs = open(input_file, 'r')

    # 读取fastq文件
    i=0
    while True:
        line=ifs.readline()
        if not line : break # 跳出循环
        if not line.startswith('@'):
            sys.stderr.write('Please check fastq. Make 4 lines a record')
            sys.exit(1)
        name    = line  # E.G.   @M04988:24:000000000-G1H2R:1:1101:15824:1351 1:N:0:NNTGNTGT+TATTTTGT
        seq     = ifs.readline()
        symbol  = ifs.readline()
        quality = ifs.readline()

        if check_index(i7,i5,name):
            #sys.stdout.write(name+seq+symbol+quality)
            i=i+1
        else: continue

    sys.stderr.write('Total reads: %d ' %(i))

if __name__ == '__main__':
    main()

