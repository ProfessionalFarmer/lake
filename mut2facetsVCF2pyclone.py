# -*- coding: utf-8 -*-

import argparse
import gzip
import os
import sys
import logging

logging.basicConfig(
         format='%(asctime)s %(levelname)-8s %(message)s',
         level=logging.INFO,
         datefmt='%Y-%m-%d %H:%M:%S')

# ls ../snv/*mutect2.paired.filter.final.pass.vcf.gz | cut -f 3 -d '/' | cut -f 1 -d '.' | xargs -L 1 -i{} sh -c "echo python ~/software/lake/mut2facetsVCF2pyclone.py -s {} -v ../snv/{}.mutect2.paired.filter.final.pass.vcf.gz -c ../facets/{}.facets.commonsnp.vcf.gz -o ../pyclone/{}.tsv" | parallel --lb -j 60

#sys.argv = ["","-s","test","-c","/data/home2/Zhongxu/work/baiduMultiRegion/raw/facets/ESCC061T5.facets.commonsnp.vcf.gz","-v","/data/home2/Zhongxu/work/baiduMultiRegion/raw/SNV/ESCC061T5.mutect2.paired.filter.final.pass.vcf.gz"]

ap = argparse.ArgumentParser(prog=os.path.basename(sys.argv[0]),
                                 usage=__doc__)
ap.add_argument("-s", '--sample', required=True, type=str, help='Sample barcode')
ap.add_argument("-v",'--variant', required=True, type=str, help='vcf file from mutect2')
ap.add_argument("-c",'--cnv', required=True, type=str, help='Copy number file from facets.vcf.gz')
ap.add_argument("-o",'--output', required=False, type=str, help='Output file path')

args = ap.parse_args()


# input vcf
if(args.variant.endswith(".gz")):
    vf = gzip.open(args.variant, 'rt')
else:
    vf = open(args.variant, 'r')


# input facets.result
if(args.cnv.endswith(".gz")):
    cf = gzip.open(args.cnv, 'rt')
else:
    cf = open(args.cnv, 'r')


# output file
if(args.output):
    of = open(args.output, 'w')
else:
    #sys.stdout = open("/dev/stdout", "w")
    of = sys.stdout


logging.warning(args.sample)


# Parse CNV
segment_list = []
purity=""
for line in cf:
    if line.startswith("#"):
        if line.startswith("##dipLogR="):
            dipLogR = float(line.strip().split("=")[1])
            logging.warning("dipLogR"+"\t"+str(dipLogR))
            dipLogR = round(dipLogR, 3)
        elif line.startswith("##purity="):
            #purity will be NA if Insufficient information to estimate purity. Likely diplod or purity too low.
            purity = float(line.strip().split("=")[1])
            purity = str(round(purity, 3))
            logging.warning("purity"+"\t"+str(purity))
        continue

    line = line.strip()

    l_list =line.split("\t")

    seg_chr  = l_list[0]
    seg_star = l_list[1]

    info_map = { tmp.split("=")[0]:tmp.split("=")[1] for tmp in l_list[7].split(";")}
    info_map["START"] = seg_star
    info_map["CHR"] = seg_chr
    segment_list.append(info_map)
    # CNLR_MEDIAN,Number=1,Type=Float,Description="Median log-ratio (logR) of the segment. logR is defined by the log-ratio of total read depth in the tumor versus that  in the normal
    ##INFO=<ID=CF_EM,Number=1,Type=Float,Description="Cellular fraction, fraction of DNA associated with the aberrant genotype. Set to 1 for normal diploid">
    ##INFO=<ID=TCN_EM,Number=1,Type=Integer,Description="Total copy number. 2 for normal diploid">
    ##INFO=<ID=LCN_EM,Number=1,Type=Integer,Description="Lesser (minor) copy number. 1 for normal diploid">
    # SVTYPE=HEMIZYG;SVLEN=154831350;END=156028050;NUM_MARK=13252;NHET=18;CNLR_MEDIAN=-0.033;MAF_R=-0.006;SEGCLUST=17;CNLR_MEDIAN_CLUST=-0.007;MAF_R_CLUST=.;CF_EM=1;TCN_EM=1;LCN_EM=.;CNV_ANN=.

# parse vcf total_copy_number
of.write("mutation_id\tsample_id\tref_counts\talt_counts\tmajor_cn\tminor_cn\tnormal_cn\ttumour_content\n")
for line in vf:
    if line.startswith("#"): continue

    line = line.strip()
    l_list =line.split("\t")

    snv_chr = l_list[0]
    snv_pos = l_list[1]
    snv_ref = l_list[3]
    snv_alt = l_list[4]

    mutation_id = args.sample + ":" + snv_chr + ":" + snv_pos + ":" + snv_ref
    # 不考虑1/2型
    if "," in snv_alt: continue

    # 第十列（9）是normal的，第十一列（10）才是tumor的
    # 如果是L的话，则第十列是L
    infoIndex = 10
    if( "L" in  args.sample ):
        infoIndex = 9

    ref_alt_ad = l_list[infoIndex].split(":")[1]
    ref_counts = ref_alt_ad.split(",")[0]
    alt_counts = ref_alt_ad.split(",")[1]
    snv_genotype = l_list[infoIndex].split(":")[0]


    major_cn = ""
    minor_cn = ""
    normal_cn = "2"
    if snv_chr == "X" or snv_chr == "chrX": normal_cn = "1"
    tumour_content = purity

    isFindSegment = False
    for segment in segment_list:
        if(not snv_chr == segment["CHR"]): continue
        # find segment information
        if(int(snv_pos) >= int(segment["START"]) and int(snv_pos) <= int(segment["END"])):
            isFindSegment = True
            total_cn = segment["TCN_EM"]
            if total_cn == "." or total_cn == "": 
                logging.warning("Not consider")
                logging.warning(segment)
                continue

            minor_cn = segment["LCN_EM"]
            if(segment["SVTYPE"]=="NEUTR"):
                total_cn = "2"
                minor_cn = "1"
            if(minor_cn=="."):
                if(int(total_cn)==0 or int(total_cn)==1): 
                    minor_cn="0"
                else:
                    isFindSegment = False 
                    logging.warning("Not consider")
                    logging.warning(segment)
                    continue

            major_cn = str(int(total_cn)-int(minor_cn))

    if(not isFindSegment):
        logging.warning("Not find segment information for "+"\t"+str(snv_chr)+"\t"+str(snv_pos)+"\t"+str(snv_alt))
        #sys.exit(1)
    else:
        ## don't consider normal CN
        #if(major_cn=="1" and minor_cn=="1"):
        #    continue
        of.write(mutation_id+"\t"+args.sample+"\t"+ref_counts+"\t"+alt_counts+"\t"+major_cn+"\t"+minor_cn+"\t"+normal_cn+"\t"+str(tumour_content)+"\n")

    #sys.exit(1)

of.flush()
if(not of == sys.stdout): of.close()

