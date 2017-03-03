# -*- coding: utf-8 -*-
#! /usr/bin/python
# Create on: 20160413
# Modify on:
# Futher add synonymous and non-synonymous stat
__author__ = 'Jason'

import getopt
import sys
import os
import time

col_sep='\t'

def getopts():
    try:
        options,args = getopt.getopt(sys.argv[1:],"i:o:",[''])
        return options
    except getopt.GetoptError:
        print '''
        Just draw base change type based on single sample vcf or annovar file.
        program.py -i InputFile -o Path.
        Support stdin
        '''
        sys.exit()


def stat(list):
    total_num,total_snv,total_indel=0,0,0
    ts,tv=0,0
    dbsnp_num=0
    hom,het=0,0
    for i,line in enumerate(list):
        if i==0:
            for tmp in line.split(col_sep):
                if 'avsnp' in tmp:
                    dbsnp_col_index=line.split(col_sep).index(tmp)
                    break
            continue
        ## stat
        t=line.split(col_sep)
        total_num+=1
        if 'rs' in t[dbsnp_col_index]:
            dbsnp_num+=1
        ref=t[3]
        alt=t[4]
        if 'hom' in line:
            hom+=1
        elif 'het' in line:
            het+=1
        if '-' in ref or '-' in alt or len(ref)!=len(alt):
            total_indel+=1
            continue
        else: total_snv+=1
        if '%s%s'%(ref,alt) in ['AG','GA','CT','TC']:
            ts+=1
        elif '%s%s'%(ref,alt) in ['AT','AC','GC','GT','CA','CG','TA','TG']:
            tv+=1

    dbsnp_count_df_str='type = c("novel", "in dbsnp"), count = c(%.0f,%.0f)' % (total_num-dbsnp_num,dbsnp_num)
    ts_tv_count_df_dtr='type = c("ts", "tv"), count= c(%.0f,%.0f)' % (ts,tv)
    snv_indel_df_str='type = c("SNV", "INDEL"), count= c(%.0f,%.0f)' % (total_snv,total_indel)
    hom_het_df_str='type = c("hom", "het"), count= c(%.0f,%.0f)' % (hom,het)

    t='''#! /usr/bin/Rscript
library(ggplot2)
library(grid)
df <- data.frame(%s)
f1 <- ggplot(df, aes(type, count)) +  geom_bar(stat = "identity" ,fill="#56B4E9")  + labs(x="in dbSNP",y="count") +geom_text(aes(label=count,y=count+2000)) + theme(panel.background = element_blank())
df <- data.frame(%s)
f2 <- ggplot(df, aes(type, count)) +  geom_bar(stat = "identity" ,fill="#56B4E9") + labs(x="ts/tv",y="count") + geom_text(aes(label=count,y=count+2000)) + theme(panel.background = element_blank()) 
df <- data.frame(%s)
f3 <- ggplot(df, aes(type, count)) +  geom_bar(stat = "identity", fill="#56B4E9") + labs(x="SNV/INDEL",y="count") + geom_text(aes(label=count,y=count+2000)) + theme(panel.background = element_blank())
df <- data.frame(%s)
f4 <- ggplot(df, aes(type, count)) +  geom_bar(stat = "identity", fill="#56B4E9") + labs(x="hom/het",y="count") + geom_text(aes(label=count,y=count+2000)) + theme(panel.background = element_blank())


png(file="**out_path**")
vplayout <- function(x, y) viewport(layout.pos.row = x, layout.pos.col = y)
grid.newpage()
pushViewport(viewport(layout = grid.layout(1, 4)))
print(f1, vp = vplayout(1, 1))
print(f2, vp = vplayout(1, 2))
print(f3, vp = vplayout(1, 3))
print(f4, vp = vplayout(1, 4))
dev.off()

svg(file="**out_path**.svg")
vplayout <- function(x, y) viewport(layout.pos.row = x, layout.pos.col = y)
grid.newpage()
pushViewport(viewport(layout = grid.layout(1, 4)))
print(f1, vp = vplayout(1, 1))
print(f2, vp = vplayout(1, 2))
print(f3, vp = vplayout(1, 3))
print(f4, vp = vplayout(1, 4))
dev.off()

'''%(dbsnp_count_df_str,ts_tv_count_df_dtr,snv_indel_df_str,hom_het_df_str)
    return t


def main():
    #sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\HQG.filter.revised.annotation.txt','-o','sss']
    ifs=sys.stdin
    opts=getopts()
    out_path=None,None
    for key,value in opts:
        if key in ('-i'):
            ifs=open(value)
            continue
        if key in ('-o'):
            out_path=value
            continue
    if out_path==None:
        print 'Please set out figure path'
        sys.exit()
    print'Stat data'
    list=[ line.strip() for line in ifs]
    script_str=stat(list)
    script_path=os.getcwd()+os.sep+'script_mutation.R.sh'
    script=open(script_path,'w')
    script.write(script_str.replace('**out_path**',out_path))
    script.flush()
    script.close()
    print 'Draw figur'
    os.system('chmod 755 %s\n' % script_path)
    time.sleep(1)
    os.system('%s\n'%script_path)
    time.sleep(1)
    os.system('rm %s'%(script_path))

if __name__=='__main__':
    main()



