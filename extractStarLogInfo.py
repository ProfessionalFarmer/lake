#######################################################################################
###                                                                                 ###
###     Copyright (C) 2020  Zhongxu ZHU, CityU, 20201105                            ###
#######################################################################################
# ls | grep SRR | awk '{print "python ~/software/lake/extractStarLogInfo.py --sample "$1" --log "$1"/"$1".starLog.final.out" }' | parallel -j 1
#

import sys,os
import argparse
#import numpy as np
import gzip


ap = argparse.ArgumentParser(prog=os.path.basename(sys.argv[0]),
                                 usage=__doc__)
ap.add_argument('--sample', required=True, type=str, help='Sample ID')
ap.add_argument('--log', type=str, help='STAR Final log file')

args = ap.parse_args()


if args.log:
    if args.log.endswith("Log.final.out"):
        ips = open(args.log)
    else:
        sys.stderr.write("Error in --log option")
        sys.exit(1)
else:
    ips = sys.stdin


#sys.stderr.write(args.sample+"\n")

total_reads = 0
uniq_mapping_rate = 0
uniq_mapping_reads = 0

for line in ips:
    line = line.strip()
    if 'Number of input reads' in line:
        total_reads = line.split("|")[1].strip()
        continue
    if 'Uniquely mapped reads number' in line:
        uniq_mapping_reads = line.split("|")[1].strip()
        continue
    if 'Uniquely mapped reads %' in line:
        uniq_mapping_rate = line.split("|")[1].strip()
        continue
#    print(line)

print("%(sample)s\t%(total)s\t%(uniq)s\t%(uniqrate)s"%({"total":total_reads,
        "uniq":uniq_mapping_reads,
        "sample":args.sample,
        "uniqrate":uniq_mapping_rate}))

ips.close()

