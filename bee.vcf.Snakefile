#configfile: "config.yaml"

import os
import glob
import sys

cINPUT_DIR  = "/data0/Zhongxu/BeeProject2/珲春黑蜂"
cOUTPUT_DIR = "/data0/Zhongxu/BeeProject2/hunchunout"

cINPUT_DIR  = "/data0/Zhongxu/BeeProject2/高加索蜂"
cOUTPUT_DIR = "/data0/Zhongxu/BeeProject2/carout"

cREF = "/data0/Zhongxu/BeeProject/ref/GCF_003254395.2_Amel_HAv3.1_genomic.fna"
cFAI = "/data0/Zhongxu/BeeProject/ref/GCF_003254395.2_Amel_HAv3.1_genomic.fna.fai"
cSPLIT = cOUTPUT_DIR +"/split"

print("Input directory", cINPUT_DIR)

(SAMPLE,) = glob_wildcards(cINPUT_DIR  + "/{sample}.Clean.R1.fastq.gz")

print(SAMPLE)
print(len(SAMPLE))

if(True):
    os.system('''
        if [ ! -d {PATH} ];then
            mkdir -p {PATH}
        fi
        cd {PATH}
        # 2000000 适合小样本，500000大样本
        bedtools makewindows -g {FAI} -w 2000000 | split -l 1 --additional-suffix .bed
    '''.format(PATH=cSPLIT, FAI=cFAI) )

(REGION,) = glob_wildcards(cSPLIT  + "/{region}.bed")


rule all:
    input:
        expand(cOUTPUT_DIR + "/{sample}/{sample}.bwa.done", sample = SAMPLE),
        cSPLIT + "/mergeVCF.done",
        cOUTPUT_DIR + "/1.raw.merged.AddTags.vcf.gz",
        cOUTPUT_DIR + "/2.filterSelectSNP.done"

rule fastp:
    input:
        R1 = cINPUT_DIR + "/{sample}.Clean.R1.fastq.gz",
        R2 = cINPUT_DIR + "/{sample}.Clean.R2.fastq.gz"
    output:
        CLEAN_R1   = temp( cOUTPUT_DIR + "/{sample}/{sample}_clean.R1.fastq.gz"),
        CLEAN_R2   = temp( cOUTPUT_DIR + "/{sample}/{sample}_clean.R2.fastq.gz"),
        Done = cOUTPUT_DIR + "/{sample}/{sample}.fastp.done"
    log: cOUTPUT_DIR + "/{sample}/log"
    benchmark: cOUTPUT_DIR + "/{sample}/benchmark.fastp.txt"
    params:
        JSON_PATH = cOUTPUT_DIR + "/{sample}/{sample}.fastp.json",
        HTML_PATH = cOUTPUT_DIR + "/{sample}/{sample}.fastp.html",
        TITLE = "{sample}",
        SAMPLE_DIR = cOUTPUT_DIR + "/{sample}",
    threads: 10
    shell:
        """
        if [ ! -d {params.SAMPLE_DIR} ];then
            mkdir -p {params.SAMPLE_DIR}
        fi

        fastp -i {input.R1} -I {input.R2} \
            -o {output.CLEAN_R1} -O {output.CLEAN_R2} --thread {threads} \
            --json {params.JSON_PATH} --html {params.HTML_PATH} --report_title {params.TITLE}  && \
        touch {output.Done}
 
        """

 

rule bwabam:
    input:
        R1 = cOUTPUT_DIR + "/{sample}/{sample}_clean.R1.fastq.gz",
        R2 = cOUTPUT_DIR + "/{sample}/{sample}_clean.R2.fastq.gz"
    output:
        BAM  =  cOUTPUT_DIR + "/{sample}/{sample}_sort_rmdup.bam",
        Done = cOUTPUT_DIR + "/{sample}/{sample}.bwa.done"
    log: cOUTPUT_DIR + "/{sample}/log"
    benchmark: cOUTPUT_DIR + "/{sample}/benchmark.bwa.txt"
    params:
        SAMPLE = "{sample}",
        REF = cREF,
        THREADS = 10
    threads: 35
    shell:
        """
        bwa-mem2 mem -M -k 32 -t {params.THREADS} -R "@RG\\tID:{params.SAMPLE}\\tSM:{params.SAMPLE}\\tLB:{params.SAMPLE}\\tPL:ILLUMINA" \
            {params.REF} \
            {input.R1} {input.R2} | \
        samtools view -hb --threads {params.THREADS} - | \
        samtools sort -O bam --threads {params.THREADS} -m 5G -o - - | \
        samtools rmdup -s - {output.BAM} && touch {output.Done} && samtools index {output.BAM} 
        """


rule bamlist:
    input:
        expand(cOUTPUT_DIR + "/{sample}/{sample}_sort_rmdup.bam", sample = SAMPLE)
    output:
        BAMLIST = dynamic( cOUTPUT_DIR + "/bamlist" )
    threads: 1
    shell:
        """
        echo "{input}" | tr " " "\\n"  > {output.BAMLIST}
        """


rule mpileup:
    input:
        BAM = cOUTPUT_DIR + "/bamlist",
        BED = cSPLIT + "/{region}.bed"
    output:
        VCF  = cSPLIT + "/{region}.bcftools.raw.vcf.gz",
        Done = cSPLIT + "/{region}.mpileup.done"
    log: cSPLIT + "/{region}.mpileup.log"
    benchmark: cSPLIT + "/{region}.benchmark.log"
    params:
        REF = cREF,
        THREADS = 2
    threads: 5
    shell:
        """
        bcftools mpileup \
            --output-type u \
            --bam-list {input.BAM} \
            --fasta-ref {params.REF} \
            --threads {params.THREADS} --regions-file {input.BED}\
            --max-depth 2000 \
            --annotate FORMAT/AD,FORMAT/DP,INFO/AD,SP | \
            bcftools call \
            -f GQ \
            --output-type z \
            --threads {params.THREADS} \
            --multiallelic-caller \
            --variants-only \
            --output {output.VCF} && tabix -f -p vcf {output.VCF}  &&  touch {output.Done}
        """


rule mergeVCF:
    input:
        expand(cSPLIT + "/{region}.bcftools.raw.vcf.gz", region = REGION)
    output:
        VCFLIST  = cSPLIT + "/vcflist",
        Done = cSPLIT + "/mergeVCF.done",
        VCF = cOUTPUT_DIR + "/1.raw.merged.vcf.gz",
        VCFADDTAG = cOUTPUT_DIR + "/1.raw.merged.AddTags.vcf.gz"
    log: cOUTPUT_DIR + "/1.mergeVCF.log"
    benchmark: cOUTPUT_DIR + "/1.mergeVCF.benchmark.log"
    params:
        REF = cREF
    threads: 50
    shell:
        """
        echo "{input}" | tr " " "\\n" | sort > {output.VCFLIST} && \
        bcftools concat -f {output.VCFLIST} --threads {threads}  --output-type z --min-PQ 0 --naive --output {output.VCF}
        ##### add tags
        export BCFTOOLS_PLUGINS=/data0/Zhongxu/BeeProject/soft/bcftools/plugins
        bcftools +fill-tags --threads {threads} --output-type z --output {output.VCFADDTAG} {output.VCF} && \
            tabix -f -p vcf {output.VCFADDTAG} && touch {output.Done}
        """
    

rule filterSelectSNP:
    input:
        VCF = cOUTPUT_DIR + "/1.raw.merged.AddTags.vcf.gz"
    output:
        VCF = cOUTPUT_DIR + "/2.raw.onlySNPs.vcf.gz",
        Done = cOUTPUT_DIR + "/2.filterSelectSNP.done"
    log: cOUTPUT_DIR + "/2.filterSelectSNP.log"
    benchmark: cOUTPUT_DIR + "/2.filterSelectSNP.benchmark.log"
    params:
        THREADS = 8
    threads: 50
    shell:
        """
        # -q minimum allele frequency (INFO/AC / INFO/AN) of sites to be printed
        zcat {input.VCF} | vcfutils.pl varFilter -w 5 -e 0.000001 |\
        bcftools view -m2 -M2 -v snps - --threads {params.THREADS} | \
            bcftools view --threads {params.THREADS} -e "INFO/DP > 50000"      | \
            bcftools view --threads {params.THREADS} -e "INFO/DP < 5"        | \
            bcftools view --threads {params.THREADS} -e "QUAL < 30"            | \
            bcftools view --threads {params.THREADS} -e "AN == 0"              | \
            bcftools view --threads {params.THREADS} --output-type z -o {output.VCF} && tabix -f -p vcf {output.VCF} && \
        touch  {output.Done}
        """
