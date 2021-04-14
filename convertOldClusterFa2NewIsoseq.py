import sys
import argparse
################
### Legacy Isoseq clustred fasta is not suitable for being integrated into new Isoseq analysis pipeline.
### This script will convert leagcy fasta to new isoseq clustered fasta which will can be easily integrated into new pipelines.
### A fasta file and a fake cluster report file will be generated.
#################

#sys.argv = ["", 
#           "-f", "/dataserver145/genomics/zhongxu/work/HCC-organoid-AS/analysis/01pbdata/10/2.corrected.fasta",
#           "-o", "/dataserver145/genomics/zhongxu/work/HCC-organoid-AS/analysis/01pbdata/10/2.corrected.reformated.fasta"
#           ]

parser = argparse.ArgumentParser(description='Process description',prog='PROG', usage='%(prog)s [options]')

parser.add_argument('-f',metavar='File path',action = 'store',type = str ,dest = 'fasta',
                     default='',help="Tofu clustered fasta file with coverage information", required=True)
parser.add_argument('-o', metavar='Reformated fasta', action = 'store',type = str ,dest = 'outputfasta',
                     default='', help="A file can integrate into new cupcake pipeline", required=True)
args = parser.parse_args()


outputfasta = open(args.outputfasta,"w")
outputClusterReport = open(args.outputfasta.replace("fasta","cluster_report.csv"),"w")
outputClusterReport.write("cluster_id,read_id,read_type\n")



n=0
for line in open(args.fasta):

    if not line.startswith(">"): 
      outputfasta.write(line)
      continue
    
    # 原来>c526607/2/1608 isoform=c526607;full_length_coverage=2;isoform_length=1608
    # 要变为>transcript/0 full_length_coverage=2;length=8254
    l_split = line.split(";")
    #print(l_split)
    transcriptName = l_split[0].split(" ")[0].strip(">")

    fullLengthCoverage=l_split[1].split("=")[1]
    length=l_split[2].strip().split("=")[1]

    outputfasta.write(">transcript/" + str(n) + " full_length_coverage=" + fullLengthCoverage + ";length=" + length + "\n") 

    for i in range(1,(int(fullLengthCoverage)+1)):
        # cluster report的格式
        # transcript/0,m54219_191225_202742/5768078/ccs,FL
        outputClusterReport.write("transcript/" + str(n) + "," + transcriptName + str(i) + "/ccs,FL\n")

    n=n+1


outputfasta.close()
outputClusterReport.close()


