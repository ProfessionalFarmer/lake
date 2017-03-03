#!/usr/bin/env python
# Create on: 201600824. https://www.biostars.org/p/140471/
# ./extract_gtf_attributes_of_interest.py < foo.gtf > answer.txt
# cat foo.gtf |  **py > 


import sys

input_stream=sys.stdin
if len(sys.argv)==2:
    input_stream=open(sys.argv[1],'r')


for line in input_stream:
    if line.startswith('#'): continue
    attr = dict(item.strip().split(' ') for item in line.split('\t')[8].strip('\n').split(';') if item)
    print attr['gene_id'].strip('\"') + '\t' + attr['gene_name'].strip('\"')


