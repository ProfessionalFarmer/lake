#! /bin/bash
# Author: Jason Zhu
# Create on: 20160602
# Take fastq as input, then go through alignment

samtools_dir='/data/SG/Env/software_installed/samtools-1.2/'
trimmoatic='/data/SG/Env/software_installed/Trimmomatic-0.33/trimmomatic-0.33.jar'
fastqc='/data/SG/Env/software_packages/FastQC/fastqc'
bismark_dir='/home/zzx/bismark_v0.16.1/'
genome_folder='/home/zzx/ref'
bowtie_dir='/home/zzx/bowtie2-2.2.9/'
fq1=""
fq2=""
# project name
project=""
# temp dir
dir="./"


while getopts "1:2:p:d:" arg ## arg is option
do
    case $arg in 
        1) 
            fq1="$OPTARG" # arguments stored in $OPTARG
            ;;
        2)
            fq2="$OPTARG"
            ;;
        p)
            project="$OPTARG"
            ;;
        d)
            dir="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

echo -e "Project name: $project\nWorking directory: $dir"

# check options
if [[ ! -f "$fq1" || ! -f "$fq2" ]];then
    echo "Please set fastq input by -1 and -2 option"
    exit 1
fi

if [ -z "$project" ];then
    echo "Please set a project name by -p option"
    exit 1
fi

if [ ! -d "$dir" ];then
    mkdir "$dir"
fi



echo -e "\n###################\n`date`: start trimmomatic"
java -jar  $trimmoatic PE  -threads 8 -phred33 $fq1  $fq2  ${dir}/${project}.clean.R1.fastq  ${dir}/${project}.clean.R1.unpaired.fastq  ${dir}/${project}.clean.R2.fastq   ${dir}/${project}.clean.R2.unpaired.fastq ILLUMINACLIP:/data/SG/Env/software_installed/Trimmomatic-0.33/adapters/zzdxadaptor.fa:2:30:10:8:TRUE LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:36
#echo "`date`: end trimmomatic"



echo -e "\n###################\n`date`: Fastqc report"
$fastqc -t 8 ${dir}/${project}.clean.R1.fastq  ${dir}/${project}.clean.R2.fastq -o $dir
echo "`date`: End Fastqc"



echo -e "\n###################\n`date`: bismark alignment"
# Specifying --basename in conjuction with --multicore is currently not supported (but we are aiming to fix this soon).
# 后续添加--multicore参数
# --best does not affect which alignments are considered "valid" by Bowtie, only which valid alignments are reported by Bowtie. 
# --non_bs_mm Optionally outputs an extra column specifying the number of non-bisulfite mismatches a read during the alignment step. 
# --gzip   Temporary bisulfite conversion files will be written out in a GZIP compressed form to save disk space.
# --nucleotide_coverage 该选项 会生成nucleotide_stats.txt文件
# creates a '...nucleotide_stats.txt' file that is also automatically detected by bismark2report and incorporated into the HTML report.
# --multicore Sets the number of parallel instances of Bismark to be run concurrently.  一个实例已经将1个核分配给bismark，两个或者4个核分配给bowtie2，一个分给samtools

$bismark_dir/bismark --genome_folder $genome_folder --bowtie2 --nucleotide_coverage --non_bs_mm --basename $project --temp_dir $dir --samtools_path $samtools_dir --path_to_bowtie $bowtie_dir -1 ${dir}/${project}.clean.R1.fastq -2 ${dir}/${project}.clean.R2.fastq --output_dir $dir
echo "`date`: end alignment"



echo -e "\n###################\n`date`: dedup"
$bismark_dir/deduplicate_bismark --paired --bam --samtools_path $samtools_dir ${dir}/${project}_pe.bam
echo "`date`: preprocess Done"


# --remove_spaces Replaces whitespaces in the sequence ID field with underscores to allow sorting.
# --cytosine_report 指报道全基因组所有的CpG。只有当指定--cytosine_report时才需要genome_folder。生成的文件很大   After the conversion to bedGraph has completed, the option --cytosine_report produces a genome-wide methylation report for all cytosines in the genome. By default, the output uses 1-based chromosome coordinates (zero-based cords are optional) and reports CpG context only (all cytosine context is optional). 
# --bedGraph   指将产生一个BedGraph文件存储CpG的甲基化信息
# --counts    指在bedGraph中有每个C上甲基化reads和非甲基化reads的数目
# --genome_folder    后跟着参考基因组的位置
# --no_overlap  Suppresses the Bismark version header line in all output files for more convenient batch processing. This option avoids scoring overlapping methylation calls twice (only methylation calls of read 1 are used for in the process since read 1 has historically higher quality basecalls than read 2). 
# --paired-end Input file(s) are Bismark result file(s) generated from paired-end read data.
# --comprehensive  指把四条链的结果合并为一个文件 Specifying this option will merge all four possible strand-specific methylation info into context-dependent output files.
# --cutoff [threshold]  The minimum number of times a methylation state has to be seen for that nucleotide before its methylation percentage is reported. Default: 1 (i.e. all covered cytosines)
# bismark extractor不支持sort后的bam文件，可能因为sort之后，配对的read不在连续的两行。 This might be a result of sorting the paired-end SAM/BAM files by chromosomal position which is not compatible with correct methylation extraction. Please use an unsorted file instead
# --no_header Suppresses the Bismark version header line in all output files for more convenient batch processing
# --CX/--CX_context  bedGrap中包含CpG context以外的
# --multicore <int> Sets the number of cores to be used for the methylation extraction process.


echo -e "\n###################\n`date`: Methylation extractor "
$bismark_dir/bismark_methylation_extractor --comprehensive --paired-end --bedGraph --no_overlap --counts --remove_spaces --multicore 8 --buffer_size 10G --cutoff 1 --output $dir ${dir}/${project}_pe.deduplicated.bam 
echo "`date`: end extracting"



echo -e "\n###################\n`date`: generate bismark report "
$bismark_dir/bismark2report ${dir}/${project}_PE_report.txt
echo "`date`: project done!!!"
