#! /bin/bash
# git clone https://github.com/broadinstitute/picard.git 
# cd picard/
# ./gradlew shadowJar
# ./gradlew jar

# absolute path
picard='/home/zzx/software/picard-tools-2.3.0/picard.jar'

# chain file http://hgdownload.cse.ucsc.edu/goldenPath/hg38/liftOver/hg38ToHg19.over.chain.gz

in=''
out=''
# absolute path
chain="/home/zzx/ref/hg38ToHg19.over.chain"
# fasta file must have dict file and fasta file must be targe genome fa.
ref='/home/zzx/ref/ucsc.hg19.fasta'



while getopts "i:o:" arg ## arg is option
do
    case $arg in 
        i) 
            in="$OPTARG" # arguments stored in $OPTARG
            ;;
        o)
            out="$OPTARG"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
        esac
done

if [ -z $in ] ;then
    echo "please set input file (-i option) and output file path (-o option)" 1>&2
    exit 1 
fi


# output file must suffix with vcf, this will tell picard the output format
java -jar $picard LiftoverVcf \
     I=$in \
     O=$in.out.vcf \
     CHAIN=$chain \
     REJECT=reject.${in} \
     R=$ref  1>&2


if [ ! -z $out ];then
    mv $in.out.vcf $out
else
    cat $in.out.vcf && rm $in.out.vcf
fi



