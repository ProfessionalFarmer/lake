# -*- coding: utf-8 -*-

#######################################################################################
###
###     Count Event and output mapping (just stat j and =)
###     Copyright (C) 2020  Zhongxu ZHU, CityU, 20200531
###
#######################################################################################

#! /bin/python
# mapping info e.g.: 
# Gene    EventID Event   Isoform SourceIso       Sample  Class
# MFSD9   MFSD9;A3:chr2:102723909-102726845:102723878-102726845:- A3      NM_032718       CRC003T.1330.6  CRC003T Known



__author__ = 'Jason'


import sys
import argparse
import re

parser = argparse.ArgumentParser(description='Process description',prog='PROG', usage='%(prog)s [options]')
parser.add_argument('-p',metavar='Suppa prefix',action = 'store',type = str ,dest = 'prefix',
                     default='',help="Suppa prefix", required=True)
parser.add_argument('-o',metavar='Output File path',action = 'store',type = str ,dest = 'output',
                     default='',help="Output file path", required=True)
# if provide tracking file, then we know whether the isoform from normal or tumor or both.
parser.add_argument('-t',metavar='Cuffcompare tracking file',action = 'store',type = str ,dest = 'tracking',
                     default='',help="Cunffcompare tracking file", required=True)
# we need track the orgin id based on gtf and tracking files. very complex
parser.add_argument('-g',metavar='gtf file',action = 'store',type = str ,dest = 'gtf',
                     default='',help="gtf file", required=True)


# sys.argv = ["","-p", "analysis/05suppa/merged-ASevents.ioe", "-o", "analysis/05suppa/tmp.all.ioe.count","-n", "^CRC.*-CRC", "-g", "analysis/04gtfprocessing/all.3.filter.gtf", "-t", "analysis/04gtfprocessing/all.1.cuffcompare.tracking"]


args = parser.parse_args()

asList = ['A3','A5','AF','AL','MX','RI','SE']

mapping = open(args.output,'w')

if args.gtf and not args.tracking:
        sys.stderr.write("Error in command. Should both")
if args.tracking and not args.gtf:
        sys.stderr.write("Error in command. Should both")

# parse gtf
if args.gtf:
    # id and old_id map
    id_oldid = {}
    # id and gene map
    id_gene  = {}
    id_class = {}
    for line in open(args.gtf):
        line = line.strip()
        if line.startswith('#'): continue
        infoField = line.split('\t')[8]
        infoMap = {}
        for field in infoField.split(";"):
            if field == "": continue
            field = field.strip(" ")
            infoMap[field.split(' ')[0]] = field.split(' ')[1].strip("\"")
        
        id = infoMap["transcript_id"].split("-")[1]
        id_oldid[ id ]  = infoMap["oId"]
        id_gene[  id ] = infoMap["gene_name"]
        id_class[ id ] = infoMap["class_code"]

del id
# if provide tracking file
if args.tracking:

    #parse tracking file, oldid trankingid map
    oldid_trackingid = {}
    # Tracking transcript ids map col 3.2 and col 3.1
    trackingid_oldids = {}


    for line in open(args.tracking):
        line = line.strip()
        llist = line.split('\t')

        trackingid = llist[0]
        class_code = llist[3]

        # just select j and =
        if not class_code == 'j' and  not class_code == '=':
            continue

        for i in range(4,len(llist)):
            if llist[i] == "-": continue

            oldid = llist[i].split("|")[1]
            oldid_trackingid[ oldid ] = trackingid

            if not trackingid in trackingid_oldids.keys():
                trackingid_oldids[ trackingid ] = oldid
            else:
                trackingid_oldids[ trackingid ] = trackingid_oldids[ trackingid ] + "," + oldid


mapping = open(args.output,'w')
mapping.write("Gene\tEventID\tEvent\tIsoform\tSourceIso\tSample\tClass\n")

for ase in asList:
    asContent = [l.strip() for l in open(args.prefix+"_"+ase+"_strict.ioe") if l.startswith("chr")]
    novel, known, all = 0, 0, 0
    for line in asContent:
        llist = line.split("\t")
        gene = llist[1]
        eventid = llist[2]


        for iso in llist[3].split(","):
  
            id  = iso.split("-")[1]
            
            # if we get the id, then id -> oldid -> tracking id -> all oldids related to this tracking id
            # then we known the class code and sample
            
            # get old id
            oldid = id_oldid[id]
            
            # get tracking id
            trackingid = oldid_trackingid[oldid]
            
            # get all old ids related to this tracking id
            idlist = trackingid_oldids[trackingid].split(",")
            
            for idtmp in idlist:
                smptmp = idtmp.split(".")[0]
                
                if id_class[id] == 'j':
                    mapping.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\n"%(gene, eventid, ase, id, idtmp, smptmp, "Novel"))
                elif id_class[id] == '=':
                    mapping.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\n"%(gene, eventid, ase, id, idtmp, smptmp, "Known"))

mapping.close()


sys.stderr.write("Done\n")
