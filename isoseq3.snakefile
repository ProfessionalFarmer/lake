#cofing.yaml
#samples:
#        HC_cl797T_RL: /path/to/RawData/HC_cl797T_RL/P92Y21404624_r64116_20210416_005156_4_D01.subreads.bam
#        HC_cl822T_RL: /path/to/RawData/HC_cl822T_RL/P92Y21404624_r64116_20210416_005156_4_D01.subreads.bam
#        HC_cl910T_RL: /path/to/RawData/HC_cl910T_RL/P92Y21404624_r64116_20210416_005156_4_D01.subreads.bam
#        HC_clHKCI1_RL: /path/to/RawData/HC_clHKCI1_RL/P92Y21404623_r64116_20210416_005156_3_C01.subreads.bam
#        HC_clHKCI8_RL: /path/to/RawData/HC_clHKCI8_RL/P92Y21404623_r64116_20210416_005156_3_C01.subreads.bam
#
#primer: /dataserver145/genomics/zhongxu/work/HCC-organoid-AS/analysis/01pbdata/primers.fasta
#gmapdb: /data0/Zhongxu/ref/hg38/gmap/
#dbname: hg38
#gmap: /path/to/gmap


configfile:"config.yaml"
#print (config['samples'])


gmapdb=config["gmapdb"],
dbname=config["dbname"]
gmap=config["gmap"]

rule all:
    input:
        expand("{sample}/7.cupcake.collapsed.filtered.gff", sample=config["samples"])


def getSubreads(wildcards):
     return config["samples"][wildcards.sample]

rule Circular_Consensus_Sequence_calling:
     input: 
         subreads=lambda wildcards: config["samples"][wildcards.sample]
         #subreads=getSubreads
     output:
         ccs="{sample}/1pb.ccs.bam",
         report="{sample}/1pb.ccs.bam.report"
     params:
         c=r"--min-rq 0.9 --noPolish --minPasses 1"
     threads: 20
     log: "{sample}/log"
     benchmark: "{sample}/benchmark.1.ccs.txt"
     shell:
         """
         ccs {input.subreads} {output.ccs} {params.c} \
             --num-threads {threads}  --report-file {output.report} 2>&1 > {log}
         """

rule lima_remove_primer:
     input:
         subreads=lambda wildcards: config["samples"][wildcards.sample],
         bam="{sample}/1pb.ccs.bam"
     output:
         "{sample}/2pb.fl.bam"
     params: 
         primer=config["primer"],
         c="--isoseq --peek-guess --min-passes 1",
         log="{sample}/2pb.fl.bam.log"
     threads: 20
     log: "{sample}/log"
     benchmark: "{sample}/benchmark.2.lima.txt"
     shell:
         """
          lima {input.bam} {params.primer} {output} {params.c} \
             --log-file {params.log} --num-threads {threads} 2>&1 >> {log}
          mv {wildcards.sample}/2pb.fl*bam {output} 
         """

rule refine_trim_polyA:
     input:
        subreads=lambda wildcards: config["samples"][wildcards.sample],
        bam="{sample}/2pb.fl.bam"
     output:
        "{sample}/3pb.flnc.bam"
     params:
        c="--require-polya 15",
        primer=config["primer"]
     threads: 20
     log: "{sample}/log"
     benchmark: "{sample}/benchmark.3.refine.txt"
     shell:
         """
         isoseq3 refine {input.bam} {params.primer} {output} \
            --num-threads {threads} {params.c} 2>&1 >> {log}
         """


rule cluster:
     input: 
         subreads=lambda wildcards: config["samples"][wildcards.sample],
         bam="{sample}/3pb.flnc.bam"
     output:
         bam="{sample}/4pb.clustered.bam",
         csv="{sample}/4pb.clustered.cluster_report.csv"
     params:
         "--verbose --use-qvs"
     threads: 20
     log: "{sample}/log"
     benchmark: "{sample}/benchmark.4.cluster.txt"
     shell:
       """
            isoseq3 cluster {input.bam} {output.bam} --num-threads {threads} {params} 2>&1 >> {log}
       """


rule polish:
     input:
          subreads=lambda wildcards: config["samples"][wildcards.sample],
          bam="{sample}/4pb.clustered.bam"
     output:
          bam="{sample}/5pb.polished.bam",
          fastaGZ="{sample}/5pb.polished.hq.fasta.gz"
     log: "{sample}/log"
     benchmark: "{sample}/benchmark.5.polish.txt"
     threads: 20
     shell:
       """
       isoseq3 polish --num-threads {threads} {input.bam} {input.subreads} {output.bam} 2>&1 >> {log}
       """

rule gmap_align:
     input:
         subreads=lambda wildcards: config["samples"][wildcards.sample],
         fastaGZ="{sample}/5pb.polished.hq.fasta.gz",
     output:
         fasta="{sample}/5pb.polished.hq.fasta",
         sam="{sample}/6.gmap.sam",
         sortedSam="{sample}/6.gmap.sorted.sam"
     params: "-f samse -n 0 --max-intronlength-ends 10000 -z sense_force"
     log: "{sample}/log"
     benchmark: "{sample}/benchmark.6.align.txt"
     threads: 20
     shell:
       """
         zcat {input.fastaGZ} > {output.fasta} 
         {gmap} -D {gmapdb} -d {dbname} {params} -t {threads} {output.fasta} > {output.sam}  2>> {log}
          samtools sort -@{threads} {output.sam} | samtools view -h > {output.sortedSam}
       """


rule collapse:
     input:
         subreads=lambda wildcards: config["samples"][wildcards.sample],
         fasta="{sample}/5pb.polished.hq.fasta",
         sortedSam="{sample}/6.gmap.sorted.sam",
         csv="{sample}/4pb.clustered.cluster_report.csv"
     output:
         pre="{sample}/7.cupcake",
         gff="{sample}/7.cupcake.collapsed.gff",
         filteredGff="{sample}/7.cupcake.collapsed.filtered.gff"
     log: "{sample}/log"
     benchmark: "{sample}/benchmark.7.collapse.txt"
     params: "--dun-merge-5-shorter -c 0.99 -i 0.95"
     threads: 2
     shell:
       """
          touch {output.pre}
          # 0. post collpase
          collapse_isoforms_by_sam.py --input {input.fasta} {params} -s {input.sortedSam} -o {output.pre}    
          # 1. post collpased
          get_abundance_post_collapse.py {output.pre}.collapsed {input.csv}
          # 2. not use out: cupcake.collapsed.min_fl_2.gff
          # filter_by_count.py  --min_count 2 --dun_use_group_count {output.pre}.collapsed
          # 3. if collapse is run with --dun-merge-5-shorter
          filter_away_subset.py {output.pre}.collapsed
       """

