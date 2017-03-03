#!/usr/bin/env python
# Create on: 20160824
# http://seqanswers.com/forums/showthread.php?p=197579


import HTSeq
import sys

if len(sys.argv)==1:
    print 'Please set input gft/gff file for $1'
    sys.exit()

gff_file = HTSeq.GFF_Reader( sys.argv[1], end_included=True )

transcripts= {}

for feature in gff_file:
   if feature.type == "exon":
      try:
         transcript_id = feature.attr['Parent']
      except KeyError:
         try:  # for ensembl gtf file. Becuase I don't find Parent tag in its gtf file
            transcript_id = feature.attr['transcript_id']
         except KeyError:
            print 'Do not find attribut Parent or transcript_id'
            sys.exit()
      if transcript_id not in transcripts:
         transcripts[ transcript_id ] = list()
      transcripts[ transcript_id ].append( feature )
      
for transcript_id in sorted( transcripts ):      
   transcript_length = 0
   for exon in transcripts[ transcript_id ]:
      transcript_length += exon.iv.length + 1
   print transcript_id, transcript_length, len( transcripts[ transcript_id ] )


