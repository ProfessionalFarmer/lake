# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
根据-r选项中的文件，判断input的文件中的特定列是否包含-r文件中的元素
-c 选项可以跟逗号分割，指定多列，1 based
Create   on: 20160519
Modified on:
'''
import getopt
import sys
import string

col_sep='\t'

def main():
    #sys.argv=['','-i',u'C:\\Users\\Administrator\\Desktop\\tst.vcf']
    try:
        opts,args = getopt.getopt(sys.argv[1:],"i:o:r:c:f",[''])
    except getopt.GetoptError:
        print '''
        program.py
        i input
        o output
        r reflist
        f fuzzy search mode, consume efficiency
        Support stdin and sdtout.

        '''
        sys.exit()
    ifs,ofs=sys.stdin,sys.stdout
    rs_set=set()
    col=[2]
    is_fuzzy_match=False
    for key,value in opts:
        if key in ('-i'):
            ifs=open(value,'r')
            continue
        if key in ('-o'):
            ofs=open(value,'w')
            continue
        if key in ('-c'):
            col=[]
            for colomn in value.split(','):
                col.append(string.atoi(colomn))
            continue
        if key in ('-r'):
            for line in open(value,'r'):
                rs_set.add(line.strip())
            continue
        if key in ('-f'):
	    is_fuzzy_match=True
	    continue    
    for line in ifs:
        l_list=line.strip().split(col_sep)
        for col_tmp in col:
            if len(l_list)< col_tmp: continue
	    if is_fuzzy_match:
		for ele in rs_set:
		    if ele in l_list[col_tmp-1].strip():
			print line
			break
            else :
		if l_list[col_tmp-1].strip() in rs_set:
                    print line,
                    break
    ofs.flush()
    ofs.close()

if __name__=='__main__':
    main()



