#! /usr/bin/ruby
# Author: Zhongxu Zhu  Create on:
# Modify on: 20160620,the longer length of chr, the more probability to generate a link
# generate random circos links. Genome version: hg19

#chr_len={"chrM"=>16571,"chr1"=>249250621,"chr2"=>243199373,"chr3"=>198022430,"chr4"=>191154276,"chr5"=>180915260,"chr6"=>171115067,"chr7"=>159138663,"chr8"=>146364022,"chr9"=>141213431,"chr10"=>135534747,"chr11"=>135006516,"chr12"=>133851895,"chr13"=>115169878,"chr14"=>107349540,"chr15"=>102531392,"chr16"=>90354753,"chr17"=>81195210,"chr18"=>78077248,"chr19"=>59128983,"chr20"=>63025520,"chr21"=>48129895,"chr22"=>51304566,"chrX"=>155270560,"chrY"=>59373566}
# 
chr_arr=Array["chr1","chr1","chr1","chr1","chr1","chr2","chr2","chr2","chr2","chr2","chr3","chr3","chr4","chr4","chr5","chr5","chr6","chr6","chr7","chr7","chr8","chr8","chr9","chr9","chr10","chr10","chr11","chr11","chr12","chr12","chr13","chr13","chr14","chr14","chr15","chr15","chr16","chr16","chr17","chr17","chr18","chr18","chr19","chr20","chr21","chr22","chrX","chrX","chrY"]

chr_len={"chr1"=>249250621,"chr2"=>243199373,"chr3"=>198022430,"chr4"=>191154276,"chr5"=>180915260,"chr6"=>171115067,"chr7"=>159138663,"chr8"=>146364022,"chr9"=>141213431,"chr10"=>135534747,"chr11"=>135006516,"chr12"=>133851895,"chr13"=>115169878,"chr14"=>107349540,"chr15"=>102531392,"chr16"=>90354753,"chr17"=>81195210,"chr18"=>78077248,"chr19"=>59128983,"chr20"=>63025520,"chr21"=>48129895,"chr22"=>51304566,"chrX"=>155270560,"chrY"=>59373566}

max_num=120
if not ARGV.empty? then
    max_num=ARGV[0].to_i
end

for i in 1..max_num
    # get rand chr 
    c1=chr_arr[rand(chr_arr.size)]
    c2=chr_arr[rand(chr_arr.size)]
    #c1=chr_len.keys[rand(chr_len.keys.size)]
    #c2=chr_len.keys[rand(chr_len.keys.size)]
    #if c1==c2 then
    #    next
    #end  
    l1=rand(chr_len[c1]+1)
    l2=rand(chr_len[c2]+1)
    puts format("%s %d %d %s %d %d",c1,l1,l1,c2,l2,l2)
             
end




