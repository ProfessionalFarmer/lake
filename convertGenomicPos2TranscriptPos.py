# -*- coding: utf-8 -*-
#######################################################################################
###                                                                                 ###
###     Copyright (C) 2019  Zhongxu ZHU, CityU, 20200325                            ###
#######################################################################################
import sys,os
import argparse

ap = argparse.ArgumentParser(prog=os.path.basename(sys.argv[0]),
                                 usage=__doc__)
ap.add_argument('--gff', required=True, type=str,
                    help='GFF or GTF file containing annotations')
ap.add_argument('--chr', required=True, type=str,
                    help='Chromosome')
ap.add_argument('--strand', required=True, type=str,
                    help='+ or -')
ap.add_argument('--pos', required=True, type=int,
                    help='position in chromosome')
ap.add_argument('--transcript', required=True, type=str,
                    help='Transcript id')
args = ap.parse_args()


# subset lines related to transcript
transcript_info = []
for line in open(args.gff):
    if line.startswith('#'): continue
    line = line.strip()
    info_map = {}
    for ele in line.split('\t')[8].strip().split(';'):
        if ele == '': continue
        ele = ele.strip()
        info_map[ele.split(' ')[0]] = ele.split(' ')[1].strip("\"")
    if info_map['transcript_id'] == args.transcript:
        transcript_info.append(line)

#  check 
contain_boolean = False
for line in transcript_info:
    l_list = line.split('\t')
    chr = l_list[0]
    feature = l_list[2]
    start_pos = int(l_list[3])
    end_pos   = int(l_list[4])
    strand = l_list[6]
 
    if not chr == args.chr or not strand == args.strand: 
        sys.stderr.write("Error1")
        sys.exit(1)
    if args.pos > start_pos and args.pos < end_pos:
        contain_boolean = True
if not contain_boolean:
    sys.stderr.write("Error2")
    sys.exit(1)



# parse
# note feature
transcript_len = 0
pos_in_transcript = 0
l_list = ''
if args.strand == '+':
    for line in transcript_info:
        l_list = line.split("\t")
        start_pos = int(l_list[3])
        end_pos   = int(l_list[4])
        transcript_len = transcript_len + end_pos - start_pos + 1
       
        if   args.pos >= end_pos:
            # in left
            pos_in_transcript = end_pos - start_pos + pos_in_transcript + 1
        elif args.pos < end_pos:
            if args.pos >= start_pos:
                pos_in_transcript = args.pos - start_pos + pos_in_transcript + 1
            elif args.pos < start_pos:
                pos_in_transcript = pos_in_transcript + 0


elif args.strand == '-':
    for line in reversed(transcript_info):
        l_list = line.split("\t")
        start_pos = int(l_list[3])
        end_pos   = int(l_list[4])
        transcript_len = transcript_len + end_pos - start_pos + 1
        
        if   args.pos <= start_pos:
            # in left
            pos_in_transcript = end_pos - start_pos + pos_in_transcript + 1
        elif args.pos > start_pos:
            if args.pos <= end_pos:
                pos_in_transcript = end_pos - args.pos + pos_in_transcript + 1
            elif args.pos > end_pos:
                pos_in_transcript = pos_in_transcript + 0
print(transcript_len)
print(pos_in_transcript)






