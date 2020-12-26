# zcat caucasica_carnica_bee.vcf.1222.select.gz | grep -v '#' | bash ~/software/lake/vcfHhterozygosityPerVariant.sh

awk -F"\t" '{line=$0} BEGIN {
        print "CHR\tPOS\tID\tREF\tALT\tAltHetCount\tAltHomCount\tRefHomCount"
    } !/^#/ {
        if (gsub(/,/, ",", $5)==0) {
            print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t" gsub(/0\|1|1\|0|0\/1|1\/0/,"") "\t" gsub(/1\/1|1\|1/,"") "\t" gsub(/0\/0|0\|0/,"")
        } else if (gsub(/,/, ",", $5)==1) {
            print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t" gsub(/1\/0|0\/1|1\|0|0\|1|1\|2|2\|1|1\/2|2\/1/,"")","gsub(/2\/0|0\/2|2\|0|0\|2|1\|2|2\|1|1\/2|2\/1/,"",line) "\t" gsub(/1\/1|1\|1/,"")","gsub(/2\/2|2\|2/,"") "\t" gsub(/0\/0|0\|0/,"")
        }
    }'

