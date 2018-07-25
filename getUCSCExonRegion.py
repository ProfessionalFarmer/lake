# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create on: 20180720
RefGene symbol
sort -V -k 1,1 -k 2,2n
0       bin     smallint
1       name    varchar
2       chrom   varchar
3       strand  char
4       txStart int
5       txEnd   int
6       cdsStart        int
7       cdsEnd  int
8       exonCount       int
9       exonStarts      longblob
10      exonEnds        longblob
11      score   int
12      name2   varchar
13      cdsStartStat    enum
14      cdsEndStat      enum
15      exonFrames      longblob
'''

import os
import sys
reload(sys)
sys.setdefaultencoding('utf8')
from optparse import OptionParser
import  logging
logging.basicConfig(level=logging.DEBUG,# DEBUG级别以上的信息都会显示
                    format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s')

def main():

    usage = 'usage: %prog  options'
    parser = OptionParser(usage=usage)
    parser.add_option("-g", "--genome", dest="genome", action="store",type = str, metavar="GENOME", help="hg19 or hg38", default='hg19')
    parser.add_option("-f", "--file", dest="geneFile", action="store",type = str, metavar="FILE",   help="One gene symbol per line")
    (options, args) = parser.parse_args()

    logging.error('read from UCSC database')
    geneList=[line.strip() for line in open(options.geneFile) if options.geneFile]
    geneSet=set(geneList) # target gene
    if len(geneList) != len(geneSet):
        logging.error('Duplicate gene symbol in gene list file')
    geneAvaliableSet=set() #  多少基因被检索到
    
    result = os.popen('mysql -N -B -h genome-mysql.cse.ucsc.edu -A -u genome -D %(genomeVersion)s -e \'select *  from refGene \'' %{'genomeVersion':options.genome})
    for line in result:
        l_list = line.split('\t')
        exonStarts = l_list[9].rstrip(',').split(',')
        exonEnds = l_list[10].rstrip(',').split(',')
        chrom = l_list[2]
        name = l_list[1]
        name2 = l_list[12]
        score = l_list[11]
        strand = l_list[3]
        if geneSet:
            if name2 in geneSet: #  如果不为空
                geneAvaliableSet.add(name2)
            else:
                continue
        for i,t in enumerate(exonEnds):
                print ("%(chrom)s\t%(start)s\t%(end)s\t%(name)s\t%(score)s\t%(strand)s"%{'chrom':chrom,'start':exonStarts[i],'end':t,'name':name2+'-'+name+'-exon'+str(i+1),'score':score,'strand':strand})

    if len(geneSet) != len(geneAvaliableSet):
        logging.error('The following genes are not found in UCSC')
        logging.error(geneSet-geneAvaliableSet)


if __name__=='__main__':
    main()
