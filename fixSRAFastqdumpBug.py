# -*- coding: utf-8 -*-
# 20210923: If we use fastq-dump to split sra format file. There no /1 /2 information
import argparse
import gzip
import os
import sys
import uuid
import logging

logging.basicConfig(
         format='%(asctime)s %(levelname)-8s %(message)s',
         level=logging.INFO,
         datefmt='%Y-%m-%d %H:%M:%S')


# sys.argv = ["","--file","/data/home2/Zhongxu/work/cuhk-crc/publicData/anothrSource/SRR5580910_2.fastq.gz","--S"]

ap = argparse.ArgumentParser(prog=os.path.basename(sys.argv[0]),
                                 usage=__doc__)
ap.add_argument("-f", '--file', required=True, type=str, help='Fastq gzip file')
ap.add_argument("-F",'--First', help='If is R1 reads', action="store_true")
ap.add_argument("-R",'--Second', help='If is R2 reads', action="store_true")

args = ap.parse_args()

# check file name
if(not args.file.endswith("fastq.gz") and not args.file.endswith("fastq") and not args.file.endswith("fq.gz") and not args.file.endswith("fq")):
    logging.warning("Not a fastq file")
    sys.exit(1)

# check options
if(not args.First and not args.Second):
    logging.warning("Please set R1 file or R2 file by --First or --Second")
    sys.exit(1)
if(args.First and args.Second):
    logging.warning("Please only set R1 file or R2 file by --First or --Second")
    sys.exit(1)

pairedInfo = ""
if(args.First  and "1." in  args.file): pairedInfo = "/1"
if(args.Second and "2." in  args.file): pairedInfo = "/2"
if(pairedInfo == ""):
    logging.warning("Paired reads information not right")
    sys.exit(1)
    
    
# input
if(args.file.endswith(".gz")):
    f = gzip.open(args.file, 'rt')
else:
    f = open(args.file, 'r')


# out put file
uuidSuffix = uuid.uuid1()
#uuidSuffix="R1.gz"
tmpFileName = args.file + str(uuidSuffix)
o = gzip.open(tmpFileName, 'wt')
    
    
# logging.warning('Watch out!')  # will print a message to the console
logging.warning('Processing fastq file' + args.file + "\n")     

lineCount = 0 # 记录read的第几行信息，共4行
totalReads = 0 # 记录一共多少reads

success = False

for line in f:
    lineCount = lineCount + 1
    
    #if (totalReads == 15000): # for debug
    #    o.flush()
    #    o.close()
    #    sys.exit(1)
        
    if lineCount == 1: # 这一行是需要处理的read name
        readName = line.strip().split(" ")[0]
        readId = readName.split(".")[1]
        
        if(readId!=str(totalReads+1)): # 因为读到read的第一行，这个时候totalReads还没有加1，读完4行才加一
            logging.warning(readName + "is not the " + str(readId) + " read\n")
        
        o.write(readName + " " + readId + pairedInfo + '\n')
    elif lineCount == 2:
        o.write(line)
    elif lineCount == 3:
        #o.write(line)
        o.write("+\n")
    elif lineCount == 4:
        lineCount = 0
        totalReads = totalReads + 1
        o.write(line)
    else:
        logging.warning("Read not right")
        sys.exit(1)
else:
    success = True
        
o.flush()
o.close()


# move tmpfile
if(not args.file.endswith(".gz")):
    args.file = args.file + '.gz'

if success:
    logging.warning('Finished. Total reads ' + str(totalReads) + "\n")  
    os.system('mv ' + tmpFileName + " " + args.file)
else:
    logging.warning('Error: Not success. Total reads ' + str(totalReads) + "  "+ file + "\n")     

