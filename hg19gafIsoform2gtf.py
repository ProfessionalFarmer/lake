import sys, argparse
########### ZHU Zhongxu 2019-12-18
#### https://api.gdc.cancer.gov/v0/data/93ec34fc-bbc6-426e-8d4b-cde53aba66bb
#### TCGA.hg19.June2011.gaf
#### search UCSC known gene isoform, print in gtf format

parser = argparse.ArgumentParser(description="Create GTF file from input GAF file")
parser.add_argument('inputGaf', type=str,help="Input GAF file")
if len(sys.argv)==1:
    parser.print_help()
    sys.exit(1)
args = parser.parse_args()

col_EntryNumber = 0 # 66934
col_FeatureID = 1 # uc002aqk.3
col_FeatureType = 2 # transcript
col_FeatureDBSource = 3  # UCSCgene
col_FeatureDBVersion = 4 #
col_FeatureDBDate =5 # 20091206
col_FeatureSeqFileName = 6 # UCSCgene.Dec2009.fa, genomic
col_Composite = 7
col_CompositeType = 8
col_CompositeDBSource = 9 # NCBI
col_CompositeDBVersion = 10 # GRCh37
col_CompositeDBDate = 11
col_AlignmentType = 12
col_FeatureCoordinates = 13
col_CompositeCoordinates = 14 # chr15:67493369-67495236,67495886-67495935,67496382-67496486,67500900-67500996,67501800-67501882,67524152-67524235,67528317-67528406,67528746-67528842,67528968-67529158,67546897-67547074:-
col_Gene = 15 # AAGAB|79719
col_GeneLocus = 16 # chr15:67493369-67547533:-
col_FeatureAliases = 17 # NM_024666
col_FeatureInfo = 18

f = open(args.inputGaf,'r')
for line in f:
    line_list = line.strip().split('\t')
    if line_list[col_FeatureType] == 'transcript' and line_list[col_CompositeDBSource]=='NCBI':
        transcript = line_list[col_FeatureID]
        if len(line_list) == col_Gene or line_list[col_Gene]=='':
            gene = transcript
            gene_id = transcript
        else:
            gene = line_list[col_Gene].split('|')[0]
            gene_id = line_list[col_Gene].split('|')[1]
            transcript = line_list[col_FeatureAliases]
        if gene=='':
            continue
        chr = line_list[col_CompositeCoordinates].split(':')[0]
        strand = line_list[col_CompositeCoordinates].split(':')[2]
        i=0
        for coordinates in line_list[col_CompositeCoordinates].split(':')[1].split(','):
            i = i + 1
            print("{chr}\trefGene.hg19\texon\t{start}\t{end}\t.\t{strand}\t.\t\
            gene_id \"{gene_id}\"; transcript_id \"{transcript}\"; exon_number \"{exon_number}\"; exon_id \"{exon_id}\"; gene_name \"{gene_name}\";"\
                  .format(chr=chr,
                          start=coordinates.split('-')[0],
                          end=coordinates.split('-')[1],
                          strand=strand,
                          gene_id = gene_id,
                          transcript = transcript,
                          exon_number = i,
                          exon_id = transcript+'.'+str(i),
                          gene_name = gene
                          )
                  )

