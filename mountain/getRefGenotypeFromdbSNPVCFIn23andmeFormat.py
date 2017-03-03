# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
根据dbSNP的VCF文件，得到rs的参考基因型，并以23andme的格式输出：
DD II是相对于alt而言，X染色体，线粒体，只输出一个碱基
Create   on: 20160519
Modified on:
'''
import getopt
import sys

def main():
    #sys.argv=['','-i',u'C:\\Users\\Administrator\\Desktop\\tst.vcf']
    try:
        opts,args = getopt.getopt(sys.argv[1:],"i:o:r:",[''])
    except getopt.GetoptError:
        print '''
        program.py <-i VCF>
        Support stdin and sdtout.
        Input file should be vcf format
        '''
        sys.exit()
    ifs,ofs=sys.stdin,sys.stdout
    rs_set=set()
    for key,value in opts:
        if key in ('-i'):
            ifs=open(value,'r')
            continue
        if key in ('-o'):
            ofs=open(value,'w')
            continue
        if key in ('-r'):
            for line in open(value,'r'):
                rs_set.add(line.strip())
            continue
    for line in ifs:
        if line.startswith('#'): continue
        l_list=line.strip().split('\t')
        chr = l_list[0].replace('chr','')
        pos = l_list[1]
        rs = l_list[2]
        ref = l_list[3]
        # an example in vcf chrY        59363052        rs367673729     TAG     T,TG    .       .
        alt = l_list[4].split(',')[0]
        ## rs在set中才输出
        if len(rs_set)!=0 and rs not in rs_set:
            continue
        if len(ref)==1 and len(alt)==1:
            ref=ref
        elif len(alt)>len(ref):
            ref='D'
        elif len(alt)<len(ref):
            ref='I'
        else: continue
        if chr=='X' or chr=='Y' or chr=='M':
            if chr=='M': chr='MT'
            ref=ref
        else:
            ref=ref+ref
        ofs.write('%s\t%s\t%s\t%s\n' %(rs,chr,pos,ref))
    ofs.flush()
    ofs.close()

if __name__=='__main__':
    main()


