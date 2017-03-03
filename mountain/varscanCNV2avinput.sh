#! /bin/bash

cat $1 | grep -v 'chr_start' |  awk 'BEGIN{print "#chr\tstart\tend\tref\talt\tlog2ratio\ttype"} {c=(($2+$3)/2); printf ("%s\t%u\t%u\tA\tA\t%s\t%s\n",$1,c,c,$6,$8)}' 

