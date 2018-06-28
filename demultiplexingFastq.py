# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create on: 20180627
'''


import os,sys
if sys.getdefaultencoding() != 'utf-8':
    reload(sys)
    sys.setdefaultencoding('gbk')
from optparse import OptionParser
import logging  # 引入logging模块
logging.basicConfig(level=logging.DEBUG,# DEBUG级别以上的信息都会显示
                    format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s')
import gzip
import re


def checkRequiredArguments(opts, parser):
    '''

    :param opts:
    :param parser:
    :return:
    '''
    if opts.barcodefile is None:
        parser.error("Please set barcode file contain sample name and index")
    if opts.r1 is None:
        parser.error("Please set R1.fastq.gz file path")
    #if opts.r2 is None:
    #    parser.error("Please set R2.fastq.gz file path")
    if not os.path.isfile(opts.barcodefile):
        parser.error("Barcode file does not exist")



def parseBarcodeFile(barcodeFilePath):
    '''

    :param barcodeFilePath:
    :return:
    '''
    l_list = [ line.strip().split('\t') for line in open(barcodeFilePath,'r').readlines() ]
    if len(l_list) == 0:
        logging.error("Barcode file: %s is empty, please check" % barcodeFilePath)
    num_field = len (l_list[0])
    sample_list, index_map = None, None
    sample_list = [ l[0] for l in l_list]
    index_map = {l[0]:l[1] for l in l_list}
    for key, value in index_map.iteritems():
        index_map[key] = value.replace('N','\\w').replace('+','\\+')
    return sample_list, index_map

def checkIndex(read_name, index_map):
    index = read_name.split(':')[9].strip()
    count_sample_match = 0
    result_index_match = None  # 匹配的样本index
    result_index_sample = None # 匹配的样本
    for sample_name, sample_index in index_map.iteritems():
        an = re.search(sample_index, index)
        if an:
            result_index_match = sample_index
            result_index_sample = sample_name
            count_sample_match += 1
        else:
            continue
    else:
        sample_name, sample_index = None, None
    if count_sample_match == 1:
        return result_index_sample
    elif count_sample_match == 0 :
        return None
    else:
        logging.error('%s was matched more than once in barcode file: %s ' % index,index_map)
        logging.error('This reads will output into unknow.fasta.gz')
        return None


def demultiplexing(fastq_file_path, index_map, output_dir):
    output_undetermined_reads = False # whether output undetermined read to file. Close this to save time
    undetermined_file_name = 'Unknown'
    suffix = None
    if fastq_file_path.endswith('R1_001.fastq.gz'):
        suffix='R1_001.fastq.gz'
    elif fastq_file_path.endswith('R2_001.fastq.gz'):
        suffix='R2_001.fastq.gz'
    logging.info('Demultiplexing file: %s'% fastq_file_path)
    if fastq_file_path.endswith('gz'):
        input_stream = gzip.open(fastq_file_path,'rb')
    elif fastq_file_path.endswith('fastq'):
        input_stream = open(fastq_file_path,'br')
    else:
        logging.error('Fastq file is not corrected with suffix')
    # open sample file to write
    logging.info('Open sample file to write')
    sample_output_file_map={}
    for i,sample_name in enumerate(index_map):
        sample_output_file_map[sample_name] = gzip.open('%s/%s_S%i_L001_%s'% (output_dir, sample_name,i+1, suffix), 'wb')
    else:
        # open unknow file. This file name is the same in function checkIndex()
        if output_undetermined_reads: sample_output_file_map[undetermined_file_name]=gzip.open('%s/%s_S0_L001_%s'% (output_dir, undetermined_file_name, suffix), 'wb')
        sample_name=None
    logging.info('Working.....')
    read_count = 0
    while True:
        line=input_stream.readline()
        if not line : break # 跳出循环
        if not line.startswith('@'):
            logging.error('Please check fastq. Make 4 lines a record')
            sys.exit(1)
        name    = line  # E.G.   @M04988:24:000000000-G1H2R:1:1101:15824:1351 1:N:0:NNTGNTGT+TATTTTGT
        seq     = input_stream.readline()
        symbol  = input_stream.readline()
        quality = input_stream.readline()
        read_count += 1
        # check read index, return corresponded sample name
        sample_name = checkIndex(name, index_map)
        # demultiplexing
        if sample_name:
            sample_output_file_map[sample_name].write(name+seq+symbol+quality)
        else:
            if output_undetermined_reads : sample_output_file_map[undetermined_file_name].write(name+seq+symbol+quality)
    logging.info('Close sample file and finished')
    for i,sample_name in enumerate(index_map):
        sample_output_file_map[sample_name].close()
    else:
        if output_undetermined_reads: sample_output_file_map[undetermined_file_name].close()



def main():
    usage = "usage: %prog -b BarcodeFile -1 R1.fastq.gz -2 R2.fastq.gz -o OutputDir"
    #sys.argv=['','-b','C:\\Users\\T3\\Desktop\\t.txt','-1','C:\\Users\\T3\\Desktop\\Undetermined_S0_L001_R1_001.fastq.gz','-o','C:\\Users\\T3\\Desktop\\tmp']
    parser = OptionParser(usage=usage)
    parser.add_option("-b", "--barcode", dest="barcodefile", action="store",type = str, metavar="FILE",
                      help="barcode文件路径，第一列为样本名，第二列为i5 index，第三列为i7 index，i7可以为空，未知序列输出至Unknow.fastq.gz文件中")
    parser.add_option("-o", "--outpath",dest="outpath", action="store",type=str, default=os.getcwd(),metavar="PATH",
                      help="输出路径，如果未指定，这输出至当前工作路径下")
    parser.add_option("-1", "--r1",dest="r1", action="store",type=str, default=None,metavar="R1.fq.gz",
                      help="R1的fastq.gz文件")
    parser.add_option("-2", "--r2",dest="r2", action="store",type=str, default=None,metavar="R2.fq.gz",
                      help="R2的fastq.gz文件")
    (options, args) = parser.parse_args()
    checkRequiredArguments(options, parser)
    sample_list, index_map = parseBarcodeFile(options.barcodefile)
    if options.r1:
        demultiplexing(options.r1, index_map, options.outpath)
    if options.r2:
        demultiplexing(options.r2, index_map, options.outpath)


if __name__=='__main__':
    main()



