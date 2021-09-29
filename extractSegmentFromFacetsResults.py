
#######################################################################################
###                                                                                 ###
###     Copyright (C) 2020  Zhongxu ZHU, CityU, 20200325                            ###
#######################################################################################
# ls *vcf.gz | cut -f 1 -d '.' | xargs -L 1 -i{} echo " python ~/software/lake/extractSegmentFromFacetsResults.py --sample {} --vcf {}.facets.commonsnp.vcf.gz" | parallel --lb -j 1

import sys,os
import argparse
#import numpy as np
import gzip

ap = argparse.ArgumentParser(prog=os.path.basename(sys.argv[0]),
                                 usage=__doc__)
ap.add_argument('--sample', required=True, type=str, help='Sample ID')
ap.add_argument('--vcf', type=str, help='FACET.vcf')


args = ap.parse_args()


if args.vcf:
    if args.vcf.endswith("vcf.gz"):
        ips = gzip.open(args.vcf,"rt")
    elif args.vcf.endswith("vcf"):
        ips = open(args.vcf)
    else:
        sys.stderr.write("Error in vcf option")
        sys.exit(1)
else:
    ips = sys.stdin


sys.stderr.write(args.sample+"\n")

# output for CNTools
for line in ips:
    #print(line.strip())
    if line == '': 
        dipLogR = ''
        continue
    if line.startswith("#"): 
        if line.startswith("##dipLogR="):
            dipLogR = float(line.strip().split("=")[1])
            sys.stderr.write("dipLogR"+"\t"+str(dipLogR)+"\t"+"\n")
        continue

    line = line.strip()

    l_list =line.split("\t")

    seg_chr  = l_list[0]
    seg_star = l_list[1]

    info_map = { tmp.split("=")[0]:tmp.split("=")[1] for tmp in l_list[7].split(";")}

    seg_type = info_map["SVTYPE"]
    seg_len  = info_map["SVLEN"]
    seg_end  = info_map["END"]
    seg_num_marker = info_map["NUM_MARK"]
    # CNLR_MEDIAN,Number=1,Type=Float,Description="Median log-ratio (logR) of the segment. logR is defined by the log-ratio of total read depth in the tumor versus that  in the normal
    seg_cnlr = info_map["CNLR_MEDIAN"]
    ##INFO=<ID=CF_EM,Number=1,Type=Float,Description="Cellular fraction, fraction of DNA associated with the aberrant genotype. Set to 1 for normal diploid">
    seg_cellular_frac = info_map["CF_EM"]
    ##INFO=<ID=TCN_EM,Number=1,Type=Integer,Description="Total copy number. 2 for normal diploid">
    seg_total_cn = info_map["TCN_EM"]
    ##INFO=<ID=LCN_EM,Number=1,Type=Integer,Description="Lesser (minor) copy number. 1 for normal diploid">
    seg_minor_cn = info_map["LCN_EM"]


    #if seg_type =='NEUTR': continue
    seg_chr = seg_chr.replace("chr","")
  
    # https://github.com/mskcc/facets/issues/84
    # follow the authers recommendation  cnlr.median - dipLogR
    seg_cnlr = str(   round(float(seg_cnlr) - dipLogR,4)   )
    
    
    #DNAcopy format
    #ID chrom loc.start. loc.end num.mark seg.mean
    print(args.sample + '\t' + seg_chr + '\t' + seg_star + '\t' + seg_end + '\t' + seg_num_marker + '\t' + seg_cnlr + '\t' + seg_type  + '\t' + seg_total_cn  + '\t' + seg_minor_cn )
    #print(seg_type,seg_total_cn,seg_minor_cn)
    #print()


#CRC001N_orgP7   1       13251   208267500       26884   0.0031  NEUTR   2       1

