# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create on: 20180703
'''


import os,sys
if sys.getdefaultencoding() != 'utf-8':
    reload(sys)
    sys.setdefaultencoding('gbk')
from optparse import OptionParser
import logging  # ����loggingģ��
logging.basicConfig(level=logging.DEBUG,# DEBUG�������ϵ���Ϣ������ʾ
                    format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s')
import pysam


def parseReadStructure(structure):
    '''
    
    :param sturcture: M��ʾUMI��T��ʾtemplate
    :return:  ����һ���ַ�����ʾ��read
    '''
    logging.info("parsing reads structure")
    len_list = []
    type_list = []
    tmp=''
    for t in structure:
        if str.isdigit(t):
            tmp=tmp+t
        else:
            if tmp == '':
                logging.error('��һ����ĸӦ��Ϊ���֣����һ����ĸӦ��Ϊ��ĸ������')
                exit(1)
            len_list.append(int(tmp))
            tmp=''
            type_list.append(t)
    read_len = 0
    if not len(len_list) == len(type_list):
        logging.error('���������������û�ж�Ӧ')
        exit(1)
    template=''
    for i,t in enumerate(len_list):
        read_len = read_len + t
        logging.info('Type %s: length %i'%(type_list[i], t))
        template = template + type_list[i] * t
    logging.info('Total read length: %i' % (read_len))
    logging.info('Read template is ----     %s' % (template))
    return template     

def moveUMI2Tag(read1,read2,r1_template,r2_template):
    umi=''
    read1_seq=read1.seq
    read2_seq=read2.seq
    read1_qual=read1.qual
    read2_qual=read2.qual
    read1_seq_new, read2_seq_new, read1_qual_new, read2_qual_new = [], [], [], []

    for i,t in enumerate(r1_template):
        if t == 'M':
	    umi = umi + read1_seq[i]
	elif t == 'T':
	    read1_seq_new.append(read1_seq[i])
            read1_qual_new.append(read1_qual[i])
    for i,t in enumerate(r2_template):
        if t == 'M':
            umi = umi + read2_seq[i]
        elif t == 'T':
            read2_seq_new.append(read2_seq[i])
            read2_qual_new.append(read2_qual[i])
    read1.seq = ''.join(read1_seq_new)
    read1.qual = ''.join(read1_qual_new)
    read2.seq = ''.join(read2_seq_new)
    read2.qual = ''.join(read2_qual_new)
    umi_tag = ('RX',umi,'Z')
    tags = read1.get_tags()
    #print read1.get_tags()
    tags.append(umi_tag)
    read1.set_tags(tags)
    read2.set_tags(tags)
    return read1,read2,umi


def main():
    usage = 'usage: %prog  options'
    parser = OptionParser(usage=usage)
    parser.add_option("-i", "--input", dest="input", action="store",type = str, metavar="FILE",
                      help="����ubam�ļ�,fastq�ļ�ת��ubam�ļ�����δ������")
    parser.add_option("-o", "--output", dest="output", action="store",type = str, metavar="FILE",
                      help="���bam�ļ�")
    parser.add_option("-1", "--1structure", dest="structure1", action="store",type = str, metavar="STRING",   help="Reads�ṹ��(B for Sample Barcode, M for molecular barcode, T for Template, and S for skip),B��S���ã�ֻ��M��T��ֻ��R1�Ľṹ��")
    parser.add_option("-2", "--2structure", dest="structure2", action="store",type = str, metavar="STRING",   help="Reads�ṹ��(B for Sample Barcode, M for molecular barcode, T for Template, and S for skip),B��S���ã�ֻ��M��T��ֻ��R2�Ľṹ��")

    (options, args) = parser.parse_args()
    if options.structure1==None or options.structure2==None:
	logging.error("Please set read strcuture for either Read1 or Read2")
	exit(1)
    r1_template = parseReadStructure(options.structure1)
    r2_template = parseReadStructure(options.structure2)
    infile = pysam.AlignmentFile(options.input, "rb", check_sq=False)
    logging.info("start working: header is \n" + str(infile.header) )
    outfile = pysam.AlignmentFile(options.output, "wb", header=infile.header)
    # check whether mate read exist
    read_count = 0
    for read1 in infile:
        read2 = infile.next()
        read_count = read_count + 2 # count total reads nunber
        if not cmp(read1.qname, read2.qname) == 0: 
            logging.error("in line "+ str(read_count)+'reads name is not corresponded. \n Read1 name: '+ read1.qname+ '\nRead2 name: '+ read2.qname)
	read1,read2,umi = moveUMI2Tag(read1,read2,r1_template,r2_template)
        outfile.write(read1)
        outfile.write(read2)
    outfile.close()

if __name__=='__main__':
    main()





