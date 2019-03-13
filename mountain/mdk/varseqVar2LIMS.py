# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create on: 20170331
ls BA170412000* | cut -f 1 -d '.' | awk '{print " -i "$1".tsv -o "$1".csv -s "$1}' | sudo xargs -L 1 /share/apps/bin/python ~/lake/varseqVar2LIMS.py 
'''
import getopt
import sys
import string
import csv

inheritanceChineseMap={
    'Autosomal dominant':'常染色体显性',
    'Autosomal recessive':'常染色体隐性',
    'X-linked recessive':'伴X隐性',
    'X-linked dominant':'伴X显性',
    'Mitochondrial':'线粒体遗传',
    'Isolated cases':'个例'
}
geneRegionChineseMap={
    'exon':'外显子',
    'intron':'内含子',
    'UTR3':'非编码区'
}
effectChineseMap={
    'synonymous_variant':'同义突变',
    'missense_variant':'错义突变',
    'inframe_insertion':'整码插入',
    '5_prime_UTR_premature_start_codon_gain_variant':'5端非编码区早起始密码子获得',
    'frameshift_variant':'移码突变',
    'disruptive_inframe_deletion':'破坏性整码缺失',
    'intron_variant':'内含子突变',
    'disruptive_inframe_insertion':'破坏性整码插入',
    '3_prime_UTR_variant':'3端非编码区突变',
    'inframe_deletion':'整码缺失',
    'stop_gained':'终止密码子获得'
}
zygosityChineseMap={
    'Homozygous Variant':'纯合',
    'Heterozygous':'杂合',
    'Reference':'参考'
}

def main():
    #sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\MDKV001-003allvariants.tsv']
    try:
        opts, args = getopt.getopt(sys.argv[1:], "i:o:s:h", [''])
    except getopt.GetoptError:
        print '''
        program.py -i <INPUT> -o <OUTPUT> -s <SAMPLE_NAME> -h
        '''
        sys.exit(1)
    sampleName=None
    input,output=None,None
    ifs,ofs=None,None
    is_print_header=False
    for key,value in opts:
        if key in ('-i'):
            input=value
            continue
        if key in ('-o'):
            output=value
            continue
        if key in ('-s'):
            sampleName=value
            continue
        if key in ('-h'):
            is_print_header=True
            continue
    if input:
        ifs=open(input,'r')
    else:
        ifs=sys.stdin
    #output='C:\\Users\\Administrator\\Desktop\\csvtest.csv'
    header=ifs.readline().rstrip().split('\t')

    if not 'Chr:Pos' in header:
        sys.stderr.write('Please append header in first line')
        sys.exit(1)
    idxDP,idxVF,idxZygosity=-1,-1,-1
    for item in header:
        if 'Read Depths (DP)' in item:
            idxDP=header.index(item)
	    if not sampleName:
		sampleName=item.split('Read')[0].strip()
            continue
        if 'VF' in item or 'Variant Allele Freq' in item:
            idxVF=header.index(item)
            continue
        if 'Zygosity' in item:
            idxZygosity=header.index(item)
            continue

    if output:
        csvfile = file(output,'wb')
    else:
        csvfile = file(sampleName+'.csv','wb')
    ofs=csv.writer(csvfile)
    if is_print_header:
        ofs.writerow(['sampleName','chrPos','geneName','readDp','variantFrequency','zygosity','geneRegion','effect','transcript','codinBaseMutation','aaMutation','rsId','inheritance'])
        print('\t'.join(['sampleName','chrPos','geneName','readDp','variantFrequency','zygosity','geneRegion','effect','transcript','codinBaseMutation','aaMutation','rsId','inheritance']))
    if idxDP==-1 or idxVF==-1 or idxZygosity==-1:
        sys.stderr.write('index error for Read Depths, idxVF ro Zygosity\n')
        sys.exit(1)

    for line in ifs:
        llist=line.rstrip('\n').split('\t')
        chrPos=llist[header.index('Chr:Pos')]
        geneName=llist[header.index('Gene Names')]
        readDp=llist[idxDP]
        variantFrequency =llist[idxVF].strip()
        #if llist[idxVF].strip()=='':
        #    sys.stderr.write('No varaint base frequency information: '+ '\t'.join(llist[0:8])+'\n')

        zygosity=llist[idxZygosity]
        geneRegion=llist[header.index('Gene Region (Combined)')]
        effect=llist[header.index('Sequence Ontology (Combined)')]
        transcript=llist[header.index('Transcript Name (Clinically Relevant)')]
        codinBaseMutation=llist[header.index('HGVS c. (Clinically Relevant)')].split(':')[1]
        if not llist[header.index('HGVS p. (Clinically Relevant)')]=='':
            aaMutation=llist[header.index('HGVS p. (Clinically Relevant)')].split(':')[1]
        else:
            aaMutation=''

        rsId=llist[header.index('RSID')].split(',')[0]
        inheritance=llist[header.index('Disorders Inheritance')].split(',')[0]
        effect=effectChineseMap[effect]


        # tranlaste to chinese discription
        geneRegion=geneRegionChineseMap[geneRegion]
        if not inheritance=='':
            inheritance=inheritanceChineseMap[inheritance]
        if zygosity:
            zygosity=zygosityChineseMap[zygosity]

        ofs.writerow([sampleName,chrPos,geneName,readDp,variantFrequency,zygosity,geneRegion,effect,transcript,codinBaseMutation,aaMutation,rsId,inheritance])
        print '\t'.join([sampleName,chrPos,geneName,readDp,variantFrequency,zygosity,geneRegion,effect,transcript,codinBaseMutation,aaMutation,rsId,inheritance])
        #ofs.close()

if __name__=='__main__':
    main()


