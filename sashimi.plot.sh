
# https://github.com/guigolab/ggsashimi

############## input_bams.tsv ################
# CRC001N CRC001N.starAligned.sortedByCoord.out.bam       N
# CRC008N CRC008N.starAligned.sortedByCoord.out.bam       N
# CRC010N CRC010N.starAligned.sortedByCoord.out.bam       N
# CRC001T CRC001T.starAligned.sortedByCoord.out.bam       T
# CRC003T CRC003T.starAligned.sortedByCoord.out.bam       T
# CRC006T CRC006T.starAligned.sortedByCoord.out.bam       T
# CRC007T CRC007T.starAligned.sortedByCoord.out.bam       T
##############################################

########### color.txt ##############
# #03a9f4
# #f44e03
######################################

/data/home2/Zhongxu/software/ggsashimi/ggsashimi.py \
	-b input_bams.tsv -c chr1:32327536-32330686 \
	-g t.gtf -o sashimi --out-strand plus --out-format svg \
	--palette color.txt -C 3
