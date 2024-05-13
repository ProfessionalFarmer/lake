
# cat("Resource: ","https://github.com/aertslab/pySCENIC/tree/master/resources", "\n")
# cat("TF:", "https://resources.aertslab.org/cistarget/tf_lists/", "\n")
# cat("motif–TF: ", "https://resources.aertslab.org/cistarget/motif2tf/motifs-v10nr_clust-nr.hgnc-m0.001-o0.0.tbl", "\n")
# cat("Database: ","https://resources.aertslab.org/cistarget/databases/homo_sapiens/hg38/refseq_r80/mc_v10_clust/gene_based/", "\n")


# set a working directory
cd ./scenic

# input
f_loom_path="mye.loom"
# output
f_output="auc_mtx.csv"

### tf
f_tfs="/master/zhu_zhong_xu/ref/Scenic/allTFs_hg38.txt"
# motif
f_motifs="/master/zhu_zhong_xu/ref/Scenic/motifs-v10nr_clust-nr.hgnc-m0.001-o0.0.tbl"
# # ranking databases
f_db_names=$(ls /master/zhu_zhong_xu/ref/Scenic/*feather | tr "\n" " ")


# 推断转录因子与候选靶基因之间的共表达模块
pyscenic grn ${f_loom_path} ${f_tfs} --sparse -o adjacencies.tsv --num_workers 20

# DNA-motif分析选择TF潜在直接结合的靶点(regulon)
pyscenic ctx adjacencies.tsv `echo ${f_db_names}` \
--annotations_fname ${f_motifs} \
--expression_mtx_fname ${f_loom_path}  \
--mode "dask_multiprocessing" \
--output regulons.csv \
--num_workers 20 \
--mask_dropouts
 
#计算Regulons的活性
pyscenic aucell ${f_loom_path} \
    regulons.csv \
    --output ${f_output} \
    --num_workers 8
