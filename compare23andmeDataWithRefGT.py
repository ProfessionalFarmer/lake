# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create   on: 20160520
Modified on:
'''
import getopt
import sys

def main():
    #sys.argv=['','-i',u'C:\\Users\\Administrator\\Desktop\\tst.vcf']
    try:
        opts,args = getopt.getopt(sys.argv[1:],"2:o:r:",[''])
    except getopt.GetoptError:
        print '''
        program.py
        Support sdtout.
        Compare 23andme raw data to ref genotype date. Ref genotype date can be generated by getRefGenotypeFromdbSNPVCFIn23andmeFormat.py script.
        23andme file format:      rsid  chromosome      position        genotype
        '''
        sys.exit()
    ifs,ofs=None,sys.stdout
    rs_refgt_map={}
    rsid_col=0
    gt_col=3
    for key,value in opts:
        if key in ('-2'):
            ifs=open(value,'r')
            continue
        if key in ('-o'):
            ofs=open(value,'w')
            continue
        if key in ('-r'):
            for line in open(value,'r'):
                rs_refgt_map[line.split('\t')[rsid_col]]=line.strip()
            continue
    if ifs==None or rs_refgt_map=={}:
        sys.stderr.write('Please set -2 option for 23andme file or set ref gt file by -r option')
        sys.exit(1)
    sys.stderr.write('''Ignore identifier with i which is 23andme internal identifier
Ignore genotye not in ref GT file
Ignore genotype with '--' which means no call there
Start working\n''')

    filter_num=0
    rs_inrefgt_set=set(rs_refgt_map.keys())
    for line in ifs:
        if line.startswith('#'): continue
        l_list=line.strip().split('\t')
        rs=l_list[rsid_col]
        gt=l_list[gt_col]
        if rs.startswith('i') or gt=='--' or gt=='__':
            filter_num+=1
            continue
        if rs in rs_inrefgt_set:
            ref_line=rs_refgt_map[rs]
            if ref_line.split('\t')[gt_col] ==gt:
                filter_num+=1
                continue
            else:
                ofs.write(line)
        else:
            filter_num+=1
            continue
    sys.stderr.write('Total filter number: %d\n'%filter_num)
    ofs.flush()
    ofs.close()

if __name__=='__main__':
    main()

