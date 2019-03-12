# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create on: 20170508

'''

import sys
import getopt

def main():
#    sys.argv=['','-r','C:\\Users\\Administrator\\Desktop\\rs.list','-v','C:\\Users\\Administrator\\Desktop\\VOL018B0.pass.vcf']
    try:
        opts, args = getopt.getopt(sys.argv[1:], "r:o:v:", [''])
    except getopt.GetoptError:
        print '''
        program.py -r <rs.list> -o <OUTPUT.txt> -v <variant.vcf>
        '''
        sys.exit(1)

    vcf,rslist_file,output=None,None,None
    for key,value in opts:
        if key in ('-r'):
            rslist_file=value
            continue
        if key in ('-o'):
            output=value
            continue
        if key in ('-v'):
            vcf=value
            continue
    if not vcf or not rslist_file:
        sys.stderr.write('Please set VCF path by -v option and rs.list path by -r option')
        sys.exit(1)
    if output:
        output=open(output,'w')
    else:
        output=sys.stdout
    rslist=[t.strip() for t in open(rslist_file,'r') if not len(t.strip())==0 ]
    rsset=set(rslist)
    vcflist=[t.strip() for t in open(vcf,'r') if not len(t.strip())==0 and not t.startswith('##')]
    output.write('SAMPLE_NAME')
    for t in rslist:
        output.write('\t'+t)
    output.write('\n'+vcflist.pop(0).strip().split('\t')[9])
    vcfRsGtMap={}
    for line in vcflist:
        rs=line.strip().split('\t')[2]
        if rs in rsset:
            genotype = line.strip().split('\t')[9].split(':')[0]
            vcfRsGtMap[rs] = genotype
            continue
    for rs in rslist:
        if rs in vcfRsGtMap.keys():
            genotype=vcfRsGtMap[rs]
            if '0/1'   == genotype:
                output.write('\t1')
            elif '1/1' == genotype:
                output.write('\t2')
            elif '1/2' == genotype:
                output.write('\t3')
        else:
            output.write('\t0')
    output.write('\n')
    output.flush()


if __name__=='__main__':
    main()


