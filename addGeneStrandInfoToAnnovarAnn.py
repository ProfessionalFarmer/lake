# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
在annovar注释文件的最后一行中添加基因正负链信息。由于基因简写重复的原因，正负链信息不一定准确
Create   on: 20160603
Modified on: 20160603 open file error
'''
import getopt
import sys

col_sep='\t'
gene_symbol_col='Gene.refGene'
#通常在第七列，以0开始，就在第六列
default_gene_symbol_col=6
# 可以通过getGeneStrandInfoFromGff.sh 得到
strand_info_file='/home/zzx/ref/gene.strand.txt'



def main():
    #sys.argv=['','-i',u'C:\\Users\\Administrator\\Desktop\\tst.vcf']
    try:
        opts,args = getopt.getopt(sys.argv[1:],"i:o:s:",[''])
    except getopt.GetoptError:
        print '''
        program.py
        i input
        o output
        s strand file. First col is gene symbol and second col is strand info
        Support stdin and sdtout.
        '''
        sys.exit()
    ifs,ofs=sys.stdin,sys.stdout
    gene_strand_map={}
    gene_symbol_set=set()
    global strand_info_file
    for key,value in opts:
        if key in ('-i'):
            ifs=open(value,'r')
            continue
        if key in ('-o'):
            ofs=open(value,'w')
            continue
        if key in ('-s'):
            strand_info_file=value
            continue

    for line in open(strand_info_file,'r'):
        gene_strand_map[line.split('\t')[0].strip()]=line.split('\t')[1].strip()
        gene_symbol_set.add(line.split('\t')[0].strip())

    sys.stderr.write(u'\n###########\n请注意，所添加的正负链信息可能不准确\n##############\n')
    for line in ifs:
	# do not ignore that stdin will read '\n', so right strip 
        line=line.rstrip('\n')
        if line.startswith('Chr\t'):
            ofs.write(line+'\tStrand\n')
            default_gene_symbol_col=line.split('\t').index(gene_symbol_col)
            continue
        gene_symbol=line.split('\t')[default_gene_symbol_col]
        if gene_symbol in gene_symbol_set:
            ofs.write(line+'\t'+gene_strand_map[gene_symbol]+'\n')
        else:
            ofs.write(line+'\t.\n')
    ofs.flush()
    ofs.close()

if __name__=='__main__':
    main()




