# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create   on: 20160429
Modified on:
'''
import getopt
import sys

colEmpty='.'
columns='PopFreqMax,SIFT_score'
# r option
# 反向过滤
is_reverse=False
def getopts():
    try:
        options,args = getopt.getopt(sys.argv[1:],"i:o:c:r",[''])
        return options
    except getopt.GetoptError:
        print '''
        program.py <-i INPUT> <-o OUTPUT> <-c ColumnName>
        Support stdin and sdtout.
        '''
        sys.exit()

def filter(list):
    """
    Filter snp without rs identifier
    :param list: raw data
    :return:
    """
    new=[]
    for i,line in enumerate(list):
        t = line.strip().split('\t')
        if i == 0:
            columns_index_list=[]
            for col in columns.strip().split(','):
                columns_index_list.append(t.index(col))
            new.append(line)
            continue
        is_rm=False
        for col_idx in columns_index_list:
            if t[col_idx]==colEmpty:
		is_rm=True
                continue
        if not is_reverse and not is_rm: # 
            new.append(line)
            continue
        elif is_reverse and is_rm:
            new.append(line)
            continue
    return new

def main():
    #sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\CHG004881_CHG004880.germlineSNV.ann']
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
        if key in ('-c'):
            global columns
            columns=value
            continue
        if key in ('-r'):
            global is_reverse
            is_reverse=True
            continue
    if input:
        ifs=open(input,'r')
    else:
        ifs=sys.stdin
    if output:
        ofs=open(output,'w')
    else:
        ofs=sys.stdout
    if not columns:
        sys.stderr.write('\nPlease set column name')
        sys.exit(1)
    list=[line for line in ifs.readlines()]
    total=len(list)-1
    list=filter(list)
    after=len(list)-1
    sys.stderr.write('Empty column filter: filter snp that has a empty value in %s.\nTotal number: %d\nAfter filter: %d\n' % (str(columns),total,after))

    for line in list:
        ofs.write(line)
    ofs.flush()
    ofs.close()

if __name__=='__main__':
    main()


