# -*- coding: utf-8 -*-
#! /usr/bin/python
# Create on: 2016-03-01
# Modify on: 2016-03-02
# read stdin,  print 'length	Reads	Bases	Q20(%)	Q30(%)	GC(%)	N(ppm)'
# Modify on: 2018-08-14   change to multiple processor mode

import threading,sys
import time

lock = threading.Lock()
import copy
from multiprocessing import Process
import multiprocessing
import logging  # 引入logging模块
logging.basicConfig(level=logging.DEBUG,  # DEBUG级别以上的信息都会显示
                    format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s')



def read_fastq_block(ifs):  # 读取block line number 行的数据，后续分给进程（not线程）
    i=0
    block_line_number=200000
    block=[]
    for l in ifs:
        block.append(l.strip())
        i = i + 1
        if i == block_line_number :
            i = 0
            #logging.info('Generate a block for statistic')
            yield block
            block = []
    else:
        #logging.info('Generate the last block for statistic')
        yield block



def state(block,n,slen,qlen,n_base_count,gc_base_count,q20,q30,i): # 每个线程的统计任务,除了block以外的变量为多线程共享变量
    #logging.info('Start a statistics --- Thread %d'%(i))
    r_n, r_slen, r_qlen = 0, 0, 0
    r_n_base_count = 0
    r_gc_base_count = 0
    r_q20, r_q30 = 0, 0

    while True:
        quality =  block.pop()# pop默认从最后一个删除，这个效率远比pop(0) 快
        symbol = block.pop()
        seq = block.pop()
        name = block.pop()
        if not name.startswith('@'):
            sys.stderr.write('please make sure a unit consist of 4 lines\n')
            sys.exit(1)
        r_n += 1
        r_slen += len(seq)
        r_qlen += 1
        for baseQ in quality:
            if ord(baseQ) >= 53:
                r_q20 += 1
            if ord(baseQ) >= 63:
                r_q30 += 1
        r_gc_base_count = seq.count('G') + r_gc_base_count + seq.count('C')
        r_n_base_count = r_n_base_count + seq.count('N')
        if len(block) == 0 :
            break
    #logging.info('Finish a statistics --- Thread %d'%(i))

    lock.acquire()
    n.value = n.value + r_n
    slen.value = slen.value + r_slen
    qlen.value = qlen.value + r_qlen
    n_base_count.value = n_base_count.value + r_n_base_count
    gc_base_count.value = gc_base_count.value + r_gc_base_count
    q20.value = q20.value + r_q20
    q30.value = q30.value + r_q30
    if n.value%5000000==0:
        logging.info('Current result:\nReads number: %s\tq20: %.2f%%\tGC: %.2f%%'%(n.value,float(q20.value)/slen.value*100,float(gc_base_count.value)/slen.value*100))

    lock.release()


def main():
    logging.info('Start working...................')
    n = multiprocessing.Value('d', 0)
    slen = multiprocessing.Value('d', 0)
    qlen = multiprocessing.Value('d', 0)
    n_base_count = multiprocessing.Value('d', 0)
    gc_base_count = multiprocessing.Value('d', 0)
    q20 = multiprocessing.Value('d', 0)
    q30 = multiprocessing.Value('d', 0)


    worker_num = 100
    check_threshold = worker_num
    threads_list=[]
    #ifs=gzip.open("C:\\Users\\T3\\Desktop\\Undetermined_S0_L001_R1_001.fastq.gz", "rb")
    ifs=sys.stdin
    for block in read_fastq_block(ifs):

        p = Process(target=state, args=(copy.deepcopy(block),n,slen,qlen,n_base_count,gc_base_count,q20,q30,check_threshold))
        p.start()
        check_threshold -= 1
        threads_list.append(p)

        if check_threshold == 0:
            for p in threads_list:
                p.join()
		p.terminate()
            else:
                threads_list = []
                check_threshold = worker_num
    else:
        for p in threads_list:
            p.join()
            p.terminate()


    n = n.value
    slen = slen.value
    qlen = qlen.value
    n_base_count = n_base_count.value
    gc_base_count = gc_base_count.value
    q20 = q20.value
    q30 = q30.value

    print 'length\tReads\tBases\tQ20(%)\tQ30(%)\tGC(%)\tN(ppm)\n',
    print '%.1f\t%d\t%d\t%.2f%%\t%.2f%%\t%.2f%%\t%.2f\n' %(slen/float(n),n,slen,q20/float(slen)*100,q30/float(slen)*100,gc_base_count/float(slen)*100,n_base_count/float(1000000))

    #print n, '\t', slen, '\t', qlen



if __name__=='__main__':
    main()


