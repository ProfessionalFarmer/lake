# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create   on: 20160201
Modified on:
sed -i.bak '/^#/d' ref_GRCh37.p5_top_level.gff3
cat ref_GRCh37.p5_top_level.gff3 | awk '{if ($3=="gene"){print $0}}' > test
rm ref_GRCh37.p5_top_level.gff3*
mv test gene.gff
'''

import getopt
import sys
import os
import re

ann_path='/home/zzx/ref/gene.gff'

def getopts():
    try:
        options,args = getopt.getopt(sys.argv[1:],"i:o:",[''])
        return options
    except getopt.GetoptError:
        print '''
        program.py -i <INPUT> -o <OUTPUT>
        Support stdin and sdtout.
        '''
        sys.exit()

def get_gene_info():
    list=[line.strip().split('\t') for line in open(ann_path,'r').readlines() if not line.startswith('#')]
    gene_infor_map={}
    for t in list:
        info=t[8]
        name = re.findall(';Name=(.+?);',info)[0]
        id= re.findall('Dbxref=GeneID:(.+?)[;|,]',info)[0]
        gene_infor_map[name]=id
    return gene_infor_map

def main():
    #sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\CHG004881_CHG004880.germlineSNV.ann']
    if not os.path.isfile(ann_path):
        sys.stderr.write('Please set gene information (from gff file)')
    opts=getopts()
    input,output=None,None
    ifs,ofs=None,None
    for key,value in opts:
        if key in ('-i'):
            input=value
            continue
        if key in ('-o'):
            output=value
            continue
    if input:
        ifs=open(input,'r')
    else:
        ifs=sys.stdin
    if output:
        ofs=open(output,'w')
    else:
        ofs=sys.stdout
    input_lines=ifs.readlines()
    gene_infor_map=get_gene_info()
    availible_gene=0
    for line in input_lines:
        l=line.strip().split('\t',1)
        t=l[0].split(',')
        for gene in t:
            if gene_infor_map.has_key(gene):
                ofs.write('%s\t%s'  % (gene,gene_infor_map[gene]) )
                availible_gene=availible_gene+1
                if len(l)>1:
                    ofs.write(l[1]+'\n')
                else:
                    ofs.write('\n')

    sys.stderr.write('Total input gene number: %d\nAvailible gene number: %d\n' %( len(input_lines), availible_gene ))
    ofs.flush()
    ofs.close()

if __name__=='__main__':
    main()

