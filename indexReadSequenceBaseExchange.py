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
    if opts.input is None:
        parser.error("Please set input file path")
    if not os.path.isfile(opts.input):
        parser.error("input file does not exist")
    if opts.index_position is None:
        parser.error("Please set index postion. 0 Based. 0 is the leftmost position")
    if opts.seq_position is None:
        parser.error("Please set sequence postion. 0 Based. 0 is the leftmost position")


def main():
    usage = "usage: %prog -i InputFile -o OutputFile"
    #sys.argv=['','-i','C:\\Users\\T3\\Desktop\\tmp\\redunt_S1_L001_R1_001.fastq.gz','-b','0','-s','149','-d']
    parser = OptionParser(usage=usage)
    parser.add_option("-i", "--input", dest="input", action="store",type = str, metavar="FILE",
                      help="输入文件")
    parser.add_option("-o", "--output",dest="output", action="store",type=str, metavar="FILE",
                      help="输出文件，可以为空，则打印到标准输出")
    parser.add_option("-b", "--index",dest="index_position", action="store",type=int, metavar="INTEGER",
                      help="INDEX的位置，从0开始，如果是0，则表示在INDEX的最前面,10000则表示在最后面")
    parser.add_option("-s", "--seq",dest="seq_position", action="store",type=int, metavar="INTEGER",
                      help="Sequence的位置，从0开始，如果是0，则表示在Sequence的最前面,10000则表示在最后面")
    parser.add_option("-d", "--direction",dest="direction", action="store_false", metavar="BOOL",default=True,
                      help="True为默认，表示从sequence上移动一定数目碱基到index上，False由-d触发，表示从index上移动一定数目碱基到sequence上")
    parser.add_option('-l',"--length",dest="length",action="store",type=int,metavar='INTEGER', default=2,
                      help="要移动的碱基数目")

    (options, args) = parser.parse_args()
    checkRequiredArguments(options, parser)

    if options.output:
        output = gzip.open(options.output, 'wb')
    else:
        output = sys.stdout

    if options.input.endswith('fastq'):
        input_stream=open(options.input,'rb')
    elif options.input.endswith('fastq.gz'):
        input_stream=gzip.open(options.input,'rb')

    while 1: # while 1比whiel True效率更高，字符串格式化
        line = input_stream.readline()
        if not line: break  #
        if not line.startswith('@'):
            logging.error('Please check fastq. Make 4 lines a record')
            sys.exit(1)
        name = line  # E.G.   @M04988:24:000000000-G1H2R:1:1101:15824:1351 1:N:0:NNTGNTGT+TATTTTGT
        seq = input_stream.readline()
        symbol = input_stream.readline()
        quality = input_stream.readline()
        name_list=name.rsplit(':',1) # index information is store in name_list[1]

        if options.direction : # from sequence to index
            tmp = seq[options.seq_position:  options.seq_position + options.length ] # store in tmp
            seq = '%s%s'%(seq[:options.seq_position], seq[options.seq_position + options.length:]) # trim seq
            name_list[1] = '%s%s%s'% (name_list[1][:options.index_position], tmp, name_list[1][options.index_position:]) # move into index
            quality = '%s%s'%(quality[:options.seq_position], quality[options.seq_position + options.length:]) # quality should be also modified
        else: # from index to sequence
            tmp = name_list[1][options.index_position:  options.index_position + options.length] # store in tmp
            name_list[1] = '%s%s'%(name_list[1][:options.index_position], name_list[1][options.index_position+options.length:]) # trim index
            seq = '%s%s%s'%(seq[:options.seq_position], tmp, seq[options.seq_position:]) # move into sequence
            quality = '%s%s%s'%(quality[:options.seq_position], '@' * options.length, quality[options.seq_position:]) # 用phread score 31（对应字符为A），30对应字符为@表示
            #quality = quality[:options.seq_position] + quality[options.seq_position:options.seq_position+options.length] + quality[options.seq_position:] # 用phread score 31（对应字符为A），30对应字符为@表示
        output.write('%s:%s%s%s%s'%(name_list[0], name_list[1], seq, symbol, quality))
    output.close()



if __name__=='__main__':
    main()


