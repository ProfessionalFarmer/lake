# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create on: 20170331, 20170508
'''
import getopt
import sys


try:
    opts, args = getopt.getopt(sys.argv[1:], "i:", [''])
except getopt.GetoptError:
    print '''
    cat *.vcf | program.py -i <Rs_list_file>
    '''
    sys.exit(1)
rsFile=''
for key,value in opts:
    if '-i' in key:
        rsFile=value
if not rsFile:
    sys.stderr.write('Please set rs list file. One rs id per line')
    sys.exit(1)
rslist=[rs.rstrip() for rs in open(rsFile,'r') if not rs.strip()=='']
rsRefMap={rs:'' for rs in rslist}
# two map combined
# {rs:{base:count}}
rsCountMap={rs:{} for rs in rslist}
rsGtMap={rs:{'0/1':0,'1/1':0,'1/2':0} for rs in rslist}
rsRefPos={rs:'' for rs in rslist}

ifs=sys.stdin
for line in ifs:
    if line.startswith('#'): continue
    line=line.rstrip()
    llist=line.split('\t')
    rs=llist[2]
    for rstmp in rslist:
        if rstmp==rs:
	    pos=llist[0]+'\t'+llist[1]
            ref=llist[3]
            alt=llist[4]
            gt=llist[9].split(':')[0]
            rsRefMap[rs]=ref
	    rsRefPos[rs]=pos
            rsBaseCountMap=rsCountMap[rs]
	    if not ref in rsBaseCountMap.keys():
		rsBaseCountMap[ref] = 0
            gtMap=rsGtMap[rs]
            if gt=='1/1':
                gtMap['1/1']=gtMap['1/1']+1
                if alt in rsBaseCountMap.keys():
                    rsBaseCountMap[alt]=rsBaseCountMap[alt]+2
                else:
                    rsBaseCountMap[alt] = 2
            elif gt=='0/1':
                gtMap['0/1'] = gtMap['0/1'] + 1
                if alt in rsBaseCountMap.keys():
                    rsBaseCountMap[alt]=rsBaseCountMap[alt]+1
                    rsBaseCountMap[ref] = rsBaseCountMap[ref] + 1
                else:
                    rsBaseCountMap[alt] = 1
                    rsBaseCountMap[ref] = 1
            elif gt=='1/2':
                gtMap['1/2'] = gtMap['1/2'] + 1
                for alttmp in alt.split(','):
                    if alttmp in rsBaseCountMap.keys():
                        rsBaseCountMap[alttmp] = rsBaseCountMap[alttmp] + 1
                    else:
                        rsBaseCountMap[alttmp] = 1
	    else:
		sys.stderr.write('Do not find genotype in VCF record')
		sys.exit(1)
            rsCountMap[rs] = rsBaseCountMap
            rsGtMap[rs]=gtMap

ofs=sys.stdout
ofs.write('RsID\tChr\tPos\tRef\n')
for rs in rslist:
    ofs.write(rs+'\t'+rsRefPos[rs]+'\t'+rsRefMap[rs]+'\t')
    rsBaseCountMap=rsCountMap[rs]
    total=0
    for base,count in rsBaseCountMap.items():
        total=total+count
    for base, count in rsBaseCountMap.items():
        ofs.write('%s\t%d\t%.3f\t'%(base,count,float(count)/total))
    ofs.write('\n')

ofs.write('RsID\tChr\tPos\tRef\n')
for rs in rslist:
    ofs.write(rs+'\t'+rsRefPos[rs]+'\t'+rsRefMap[rs]+'\t')
    gtMap=rsGtMap[rs]
    total=0
    for gt,count in gtMap.items():
        total=total+count
    if total==0: total=1
    ofs.write('0/1\t%d\t%.3f\t1/1\t%d\t%.3f\t1/2\t%d\t%f\n'%(gtMap['0/1'],gtMap['0/1']/float(total),gtMap['1/1'],gtMap['1/1']/float(total),gtMap['1/2'],gtMap['1/2']/float(total)))


ofs.flush()
ofs.close()



