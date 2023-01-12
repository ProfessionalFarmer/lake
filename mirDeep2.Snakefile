#configfile: "config.yaml"

import os
import glob

cINPUT_DIR  = "/data0/Zhongxu/work/wenzhouGC/data/20230111TissueMiRNATest/soapnuke/clean"
cOUTPUT_DIR = "/data0/Zhongxu/work/wenzhouGC/analysis/20230111Prelimenary/3tissuemiRNAtest"
cDATE = "01_01_2023"

print("Input directory", cINPUT_DIR)

(SRR,SRRI) = glob_wildcards(cINPUT_DIR  + "/{sample}/{sample_i}_1.fq.gz")

print(SRR)
print(len(SRR))

rule all:
    input:
   #     expand(cOUTPUT_DIR + "/{sample}/{sample}.analysis.done",sample = SRR),
        expand(cOUTPUT_DIR + "/{sample}/done.fastqc_clean.txt",sample = SRR),
        expand(cOUTPUT_DIR + "/{sample}/done.mirdeep2.txt",sample = SRR),
        expand(cOUTPUT_DIR + "/{sample}/miRNAs_expressed_all_samples_" + cDATE + ".csv",sample = SRR),


rule fastqc_clean:
    input:
        R1 = cINPUT_DIR  + "/{sample}/{sample}_1.fq.gz"
    resources:
        mem_mb = 40000,
        runtime_s = 345600
    output:
        Done = cOUTPUT_DIR + "/{sample}/done.fastqc_clean.txt" 
    log: cOUTPUT_DIR + "/{sample}/log"
    benchmark: cOUTPUT_DIR + "/{sample}/benchmark.fastqc_clean.txt"
    params:
        TITLE = "{sample}",
        SAMPLE_DIR = cOUTPUT_DIR + "/{sample}",
    threads: 10
    shell:
        """
        if [ ! -d {params.SAMPLE_DIR} ];then
            mkdir -p {params.SAMPLE_DIR}
        fi

        fastqc -o {params.SAMPLE_DIR} -t {threads} {input.R1} 2>&1 >> {log} && touch {output.Done}

        """


rule mirdeep2:
    input:
        R1 = cINPUT_DIR  + "/{sample}/{sample}_1.fq.gz",
    resources:
        mem_mb = 40000,
        runtime_s = 345600
    output:
        Done = cOUTPUT_DIR + "/{sample}/done.mirdeep2.txt",
        FASTQ = temp( cOUTPUT_DIR + "/{sample}/{sample}.fastq" ),
        Precessed_reads = cOUTPUT_DIR + "/{sample}/{sample}.mapper.reads_collapsed.fa", 
        Mapping_reads = cOUTPUT_DIR + "/{sample}/{sample}.mapper.reads_vs_refdb.arf", 
        Mapper_log = cOUTPUT_DIR  + "/{sample}/{sample}.mapper.log",
        Quantifier_log = cOUTPUT_DIR  + "/{sample}/{sample}.quantifier.log",
        EXPRESSION_CSV = cOUTPUT_DIR + "/{sample}/miRNAs_expressed_all_samples_" + cDATE + ".csv",
    log: cOUTPUT_DIR + "/{sample}/log"
    benchmark: cOUTPUT_DIR + "/{sample}/benchmark.mirdeep2.txt"
    params:
        TITLE = "{sample}",
        SAMPLE_DIR = cOUTPUT_DIR + "/{sample}",
        Adapter = "TGGAATTCTCGGGTGCCAAGG",
        Bowtie_Index = "/data/home2/Zhongxu/ref/hg38bowtie1idx/Homo_sapiens.GRCh38.dna.primary_assembly.fa",
        Precursor = "/data/home2/Zhongxu/ref/mirdeepHsa/hairpin_ref.fa",
        Mature = "/data/home2/Zhongxu/ref//mirdeepHsa/mature_ref.fa",
        Date = cDATE,
    threads: 10
    shell:
        """
        cd {params.SAMPLE_DIR}

        gunzip -dc {input.R1} > {output.FASTQ}
        # -s file         print processed reads to this file
        # -t file         print read mappings to this file
        # -v              outputs progress report
        mapper.pl {output.FASTQ} -e -h -i -j -k {params.Adapter} -l 18 -m -n -q -p {params.Bowtie_Index} -o {threads} -s {output.Precessed_reads} -t {output.Mapping_reads} -v 2> {output.Mapper_log}

        # -W           read counts are weighed by their number of mappings. e.g. A read maps twice so each position gets 0.5 added to its read profile
        # -p precursor.fa  miRNA precursor sequences from miRBase
        # -d    if parameter given pdfs will not be generated, otherwise pdfs will be generated
        quantifier.pl -W -T {threads} -p {params.Precursor} -m {params.Mature} -r {output.Precessed_reads} -t hsa -y {params.Date} -d 2> {output.Quantifier_log} && touch {output.Done}
         
        # final file: miRNAs_expressed_all_samples_01_01_2023.csv
        head -2 {output.EXPRESSION_CSV}
        """




