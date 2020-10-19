# Trim softclip and convert to fasta format
# pip install cigar
# samtools view bam | python script.py > sequence.fa
# mapper.pl sequence.fa -c -i -j -k TGGAATTCTCGGGTGCCAAGG -l 16 -m -n                  -q -p hg38bowtie1idx/Homo_sapiens.GRCh38.dna.primary_assembly.fa -o 10                  -s ./sample.mapper.reads_collapsed.fa -t ./sample.mapper.reads_vs_refdb.arf -v 2> ./sample.mapper.log 
# quantifier.pl -W -T 10 -p ./mirdeepHsa/hairpin_ref.fa                   -m ./mirdeepHsa/mature_ref.fa                  -r ./sample.mapper.reads_collapsed.fa -t hsa -y 01_10_2020 -d 2> ./sample.quantifier.log


import os
import sys
from cigar import Cigar


for line in sys.stdin:
    
    l_list = line.strip().split("\t")
    seq_name = l_list[0]
    cigar = l_list[5]
    seq = l_list[9]
    qual = l_list[10]

    cigar = Cigar(cigar)

    len_cusor = 0
    soft_region = []

    for cigar_u in list(cigar.items()):
        cigar_u_type = cigar_u[1]
        cigar_u_len  = cigar_u[0]
   
        if cigar_u_type == 'S':
            soft_region.extend([t for t in range(len_cusor,len_cusor+cigar_u_len)])
        
        if not cigar_u_type == 'D' or not cigar_u_type == 'N':
            len_cusor = len_cusor + cigar_u_len

        if not cigar_u_type in [ 'M', 'I', 'S', 'N', 'D' ]:
            sys.stderr.write("Error: bad cigar -- " + cigar)
            sys.exit(1)

    clean_seq = [ seq[t] for t in range(0,len(seq)) if not t in soft_region]
    clean_seq = ''.join(clean_seq)
    print(">" + seq_name + "\n" + clean_seq) 

    #clean_qual = [ qual[t] for t in range(0,len(qual)) if not t in soft_region]
    #clean_qual = ''.join(clean_qual)
    #print("@" + seq_name + "\n" + clean_seq + '\n' + '+' + clean_qual)



