
#######################################################################################
###                                                                                 ###
###     Copyright (C) 2020  Zhongxu ZHU, CityU, 20201105                            ###
#######################################################################################


import sys,os
import argparse
#import numpy as np
import gzip

ap = argparse.ArgumentParser(prog=os.path.basename(sys.argv[0]),
                                 usage=__doc__)
ap.add_argument('--vcf', type=str, help='GATK call segment result')


args = ap.parse_args()


if args.vcf:
    if args.vcf.endswith("called.seg.gz"):
        ips = gzip.open(args.vcf,"rt")
    elif args.vcf.endswith("called.seg"):
        ips = open(args.vcf)
    else:
        sys.stderr.write("Error in vcf option")
        sys.exit(1)
else:
    ips = sys.stdin



# output for CNTools
for line in ips:
    #print(line.strip())
    if line.startswith("@SQ") or line.startswith("@HD") :
        sample = ''
        continue
    if line.startswith("CONTIG"):
        continue
    if line.startswith("@RG"):
        sample = line.strip().split("\t")[2].split(":")[1]
        sys.stderr.write(sample+"\n")
        continue

    line = line.strip()

    l_list =line.split("\t")

    seg_chr  = l_list[0]
    seg_star = l_list[1]
    seg_end = l_list[2]
    seg_num_marker = l_list[3]
    seg_log_ratio = l_list[4]
    seg_call = l_list[5]
    
    #DNAcopy format
    #ID chrom loc.start. loc.end num.mark seg.mean
    print(sample + '\t' + seg_chr + '\t' + seg_star + '\t' + seg_end + '\t' + seg_num_marker + '\t' + seg_log_ratio + '\t' +  seg_call )
    #print(seg_type,seg_total_cn,seg_monor_cn)
    #print()


#CRC001N_orgP7   1       13251   208267500       26884   0.0031 + 

