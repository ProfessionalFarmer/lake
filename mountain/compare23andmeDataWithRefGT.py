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
        opts,args = getopt.getopt(sys.argv[1:],"2:o:r:a",[''])
    except getopt.GetoptError:
        print '''
        program.py -2  23andme.raw.txt -r 23andme.ref_gt.txt
        Support sdtout.
        Compare 23andme raw data to ref genotype date. Ref genotype date can be generated by getRefGenotypeFromdbSNPVCFIn23andmeFormat.py script.
        23andme file format:      rsid  chromosome      position        genotype
        Default output format is 23andme file format
        -a option will output annovar avinput file format
        '''
        sys.exit()
    ifs,ofs=None,sys.stdout
    rs_refgt_map={}
    rsid_col=0
    gt_col=3
    chr_col=1
    pos_col=2
    is_annovar_format=False
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
        if key in ('-a'):
            is_annovar_format=True
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
        chr=l_list[chr_col]
        pos=l_list[pos_col]
        if rs.startswith('i') or gt=='--' or gt=='__':
            filter_num+=1
            continue
        if rs in rs_inrefgt_set:
            ref_line=rs_refgt_map[rs]
            if ref_line.split('\t')[gt_col] ==gt:
                filter_num+=1
                continue
            else:
                if is_annovar_format:
         	    ref_base=ref_line.split('\t')[gt_col][0]
	            ref_base_count=gt.count(ref_base)
		    if len(gt)==1:
			ofs.write(chr+'\t'+pos+'\t'+pos+'\t'+ref_base+'\t'+gt[0]+'\n')
			continue
	            if ref_base_count==0 :
	                if gt[0]==gt[1]:
		            ofs.write(chr+'\t'+pos+'\t'+pos+'\t'+ref_base+'\t'+gt[0]+'\thom'+'\n')
	                else:
		            ofs.write(chr+'\t'+pos+'\t'+pos+'\t'+ref_base+'\t'+gt[0]+'\thet'+'\n')
	      	            ofs.write(chr+'\t'+pos+'\t'+pos+'\t'+ref_base+'\t'+gt[1]+'\thet'+'\n')
	            elif ref_base_count==1: # if ref_base_count==2, it means it a ref genotype  and will be filtered before 
		        ofs.write(chr+'\t'+pos+'\t'+pos+'\t'+ref_base+'\t'+gt.replace(ref_base,'')+'\thet'+'\n')
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
