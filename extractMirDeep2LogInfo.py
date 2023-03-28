#!/usr/bin/env python
# -*- coding: utf-8 -*-
#######################################################################################
###                                                                                 ###
###     Copyright (C) 2019  Zhongxu ZHU, CityU, 20230112                            ###
###                                                                                 ###
#######################################################################################

import sys,os
import argparse

ap = argparse.ArgumentParser(prog=os.path.basename(sys.argv[0]),
                                  usage=__doc__)
ap.add_argument('--dir', required=True, type=str, help='Target directory including sampple folder')

args = ap.parse_args()

dir = args.dir
#dir = "/data0/Zhongxu/work/wenzhouGC/analysis/20230111Prelimenary/3tissuemiRNAtest"
quantifier_log_suffix = ".quantifier.log"
samples = next(os.walk(dir))[1]

sys.stderr.write(" ".join(samples) + '\n')

print("Sample\ttotal\tmapped\tunmapped\t%mapped\t%unmapped")


for sample in samples:
    f = open(dir + os.sep + sample + os.sep + sample + quantifier_log_suffix)
    for line in f.readlines():
        if(line.startswith("total:")):
            l_list = line.strip().lstrip("total: ").split("\t")
            print("\t".join([sample, l_list[0], l_list[1],  l_list[2], l_list[3], l_list[4],]) )


