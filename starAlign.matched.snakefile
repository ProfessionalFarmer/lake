#configfile: "config.yaml"

import os
import glob

cINPUT_DIR  = "/storage2/crc/argo/20220926/g/cleanfq_b7_10"
# /storage2/crc/argo/20220926/h/cleanfq_b5_6
# cINPUT_DIR  = "/data1/ARGO.RNA"
cOUTPUT_DIR = "/master/zhu_zhong_xu/CRC/ARGO"

print("Input directory", cINPUT_DIR)

(SRR,SRRI,) = glob_wildcards(cINPUT_DIR  + "/{sample}/{sample_seq}_1.fq.gz")

print(SRR)
print(len(SRR))
print(len(SRRI))


rule all:
    input:
        expand(cOUTPUT_DIR + "/{sample}/{sample}.salmon.done",sample = SRR),
        expand(cOUTPUT_DIR + "/{sample}/{sample}.star.done",sample = SRR)

def get_fq1(wildcards):
    # code that returns a list of fastq files for read 1 based on *wildcards.sample* e.g.
    return sorted(glob.glob(cINPUT_DIR + "/" + wildcards.sample + "/" + wildcards.sample_seq + "_1.fq.gz"))

def get_fq2(wildcards):
    # code that returns a list of fastq files for read 2 based on *wildcards.sample*, e.g.
    return sorted(glob.glob(cINPUT_DIR + "/" + wildcards.sample + "/" + wildcards.sample_seq + "_2.fq.gz"))



rule fastp:
    input:
        R1 = cINPUT_DIR + "/{sample}",
        R2 = cINPUT_DIR + "/{sample}"
    resources:
        mem_mb = 40000,
        runtime_s = 345600
    output:
        CLEAN_R1   = temp( cOUTPUT_DIR + "/{sample}/{sample}_clean.R1.fastq.gz"),
        CLEAN_R2   = temp( cOUTPUT_DIR + "/{sample}/{sample}_clean.R2.fastq.gz")
    log: cOUTPUT_DIR + "/{sample}/log"
    benchmark: "{sample}/benchmark.fastp.txt"
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

        fastp -i {input.R1}/*_1.fq.gz -I {input.R2}/*_2.fq.gz \
            -o {output.CLEAN_R1} -O {output.CLEAN_R2} --thread {threads} \
            --json {params.JSON_PATH} --html {params.HTML_PATH} --report_title {params.TITLE} 2>&1 > {log} 


 
        """


rule salmon:
    input:
        salmon = '/master/zhu_zhong_xu/software/salmon-latest_linux_x86_64/bin/salmon',
        salmon_index = "/master/zhu_zhong_xu/CRC/transcript.gencode.salmon.idx",
        GFF = "/master/zhu_zhong_xu/CRC/all.5.filter.gtf",
        CLEAN_R1   = cOUTPUT_DIR + "/{sample}/{sample}_clean.R1.fastq.gz",
        CLEAN_R2   = cOUTPUT_DIR + "/{sample}/{sample}_clean.R2.fastq.gz",
    output:
        Done    = cOUTPUT_DIR + "/{sample}/{sample}.salmon.done",
    resources:
        mem_mb = 40000,
        runtime_s = 345600
    benchmark: "{sample}/benchmark.salmon.txt"
    log: cOUTPUT_DIR + "/{sample}/log"
    threads: 10 
    params:
        RUN_DIR = cOUTPUT_DIR + "/{sample}/",
        SALMON_OUT = cOUTPUT_DIR + "/{sample}_quant",
        FILE    = cOUTPUT_DIR + "/{sample}_quant/quant.sf",
    shell:
        """
        cd {params.RUN_DIR}

        {input.salmon} quant -i {input.salmon_index} -l A \
            -p {threads} --validateMappings \
            -g {input.GFF} -1 {input.CLEAN_R1} -2 {input.CLEAN_R2} \
            -o {params.SALMON_OUT} 2>&1 >> {log} && touch {output.Done}

        """

rule star:
    input:
        CLEAN_R1   = cOUTPUT_DIR + "/{sample}/{sample}_clean.R1.fastq.gz",
        CLEAN_R2   = cOUTPUT_DIR + "/{sample}/{sample}_clean.R2.fastq.gz",
    output:
        Done = cOUTPUT_DIR + "/{sample}/{sample}.star.done" 
    resources:
        mem_mb = 40000,
        runtime_s = 345600
    params:
        STAR = "/master/zhu_zhong_xu/CRC/starAlign.sh",
        SAMPLE_NAME = "{sample}",
        GFF = "/master/zhu_zhong_xu/CRC/all.5.filter.gtf",
        STAR_INDEX = "/master/zhu_zhong_xu/CRC/star.gencode/star",
        RSEM_INDEX = "/master/zhu_zhong_xu/CRC/star.gencode/rsem/rsem",
        OUTPUT_DIR = cOUTPUT_DIR + "/{sample}",
    threads: 25
    log: cOUTPUT_DIR + "/{sample}/log"
    benchmark: cOUTPUT_DIR + "/{sample}/benchmark.star.txt"
    shell:
        """
        bash {params.STAR} -s {params.SAMPLE_NAME} \
          -g {params.GFF} \
          -1 {input.CLEAN_R1} \
          -2 {input.CLEAN_R2} \
          -t {threads} -o {params.OUTPUT_DIR} -q -a \
          -i {params.STAR_INDEX} \
          -r {params.RSEM_INDEX} 2>&1 >> {log} && touch {output.Done}

        """



