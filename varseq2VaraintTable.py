# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create on: 20170531

'''


import sys
import getopt
import datetime

import xlrd
import xlwt
# easy_install.exe xlutils
import xlutils
from xlutils.copy import copy

def time():
    return str(datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'))


def set_style():

    style = xlwt.XFStyle() # 初始化样式

    font = xlwt.Font() # 为样式创建字体
    font.name = u'宋体' # 'Times New Roman'
    font.bold = False

  #  font.color_index = 4
    font.height = 220
    borders= xlwt.Borders()
    borders.left= 1
    borders.right= 1
    borders.top= 1
    borders.bottom= 1
    style.borders = borders

    style.font = font
    return style


def addValueToSheet(sheet,row,col,value):
    sheet.write(row, col, value, set_style())

def getGeneAndNTChange(sheet):
    geneName, ntChange = None, None
    for i in range(0,sheet.nrows):
        if 'Gene Name' == sheet.row_values(i)[0].strip():
            geneName=sheet.row_values(i)[1].strip()
        if 'Variant nt Change' == sheet.row_values(i)[0].strip():
            ntChange =  sheet.row_values(i)[1].strip()
    return geneName,ntChange

def getItemPosition(sheet,item):
    count=0
    for i in range(0, sheet.nrows):
        for tmp in sheet.row_values(i):
            if isinstance(tmp, float):
                continue
            if item == tmp.strip():
                m = i
                n = sheet.row_values(i).index(tmp)
                count += 1
    if not count==1:
        sys.stderr.write(item + ' occurs more than one place in variant table')
        sys.exit(1)
    return  m,n

def getVarseqMap(filePath,gene,ntChange):
    """

    :param filePath: varseq输出文件的路径
    :param gene: variant table中的基因名
    :param ntChange: variant table中的nt变化
    :return: 返回map
    """
    cList  = [line.rstrip('\n') for line in open(filePath).readlines()]
    header = cList.pop(0).split('\t')
    targetLine=None
    count=0
    map={}
    for line in cList:
        if gene.strip() in line and ntChange.strip() in line:
            targetLine=line.split('\t')
            count+=1
    if not count ==1 :
        sys.stderr.write('在varseq文件中没有找到突变位点')
        sys.exit(1)
    if len(header) == len(targetLine):
        for i in range(len(header)):
            map[header[i]]=targetLine[i]
    else:
        sys.stderr.write('varseq的标题与内容列数不一致')
        sys.exit(1)
    return map

def getVarseqValue(vMap,item):
    count=0
    result=None
    for key,value in vMap.items():
        if item == key:
            result=value
            count+=1
    if not count ==1 :
        sys.stderr.write(item+' 在标题中不是唯一的列')
        sys.exit(1)
    return result

def working(oldsheet,newsheet,varseqMap):
    '''
    
    :param oldsheet: 用于得到特定项目的坐标 
    :param newsheet: 在新表中插入值
    :param varseqMap: 读取的varseq数据
    :return: 
    '''
    row,col=getItemPosition(oldsheet,'Mutation Type')
    value=getVarseqValue(varseqMap,'Sequence Ontology (Combined)')
    addValueToSheet(newsheet,row+1,col,value)

    row,col=getItemPosition(oldsheet,'nt Change')
    value=getVarseqValue(varseqMap,'HGVS c. (Clinically Relevant)').split(':')[1]
    addValueToSheet(newsheet,row+1,col,value)

    row,col=getItemPosition(oldsheet,'Amino Acid Change')
    if getVarseqValue(varseqMap,'HGVS p. (Clinically Relevant)').strip()=='':
	print '没有知道HGVS命名，请确认，但程序不会终止'
	value=''
    else:
	value=getVarseqValue(varseqMap,'HGVS p. (Clinically Relevant)').split(':')[1]
    addValueToSheet(newsheet, row + 1, col, value)

#    row, col = getItemPosition(oldsheet, 'Location')
#    value = getVarseqValue(varseqMap, 'Gene Region (Combined)')
#    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'NM ID')
    value = getVarseqValue(varseqMap, 'Transcript Name (Clinically Relevant)')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'Chromosome Number')
    value = getVarseqValue(varseqMap, 'Chr:Pos').split(':')[0]
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'Chromosome Start Position')
    value = getVarseqValue(varseqMap, 'Chr:Pos').split(':')[1]
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'Population Frequency')
    value = getVarseqValue(varseqMap, 'All Indiv Freq')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'East Asia Frequency')
    value = getVarseqValue(varseqMap, 'East Asian Allele Freq (EAS_AF)')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'South Asia Frequency')
    value = getVarseqValue(varseqMap, 'South Asian Allele Freq (SAS_AF)')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'SNPID')
    value = getVarseqValue(varseqMap, 'RSID')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'SIFT')
    value = getVarseqValue(varseqMap, 'SIFT Pred')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'Polyphen2 HVAR')
    value = getVarseqValue(varseqMap, 'Polyphen2 HVAR Pred')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'Mutation Taster')
    value = getVarseqValue(varseqMap, 'MutationTaster Pred')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'MutationAssessor')
    value = getVarseqValue(varseqMap, 'MutationAssessor Pred')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'FATHMM')
    value = getVarseqValue(varseqMap, 'FATHMM Pred')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'FATHMM')
    value = getVarseqValue(varseqMap, 'FATHMM Pred')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'FATHMMKLCoding')
    value = getVarseqValue(varseqMap, 'FATHMM MKL Coding Pred')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'MetaSVM')
    value = getVarseqValue(varseqMap, 'MetaSVM Pred')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'MetaLR')
    value = getVarseqValue(varseqMap, 'MetaLR Pred')
    addValueToSheet(newsheet, row + 1, col, value)

    row, col = getItemPosition(oldsheet, 'Reliability Index')
    value = getVarseqValue(varseqMap, 'Reliability Index')
    addValueToSheet(newsheet, row + 1, col, value)

def main():
    #sys.argv=['','-x','C:\\Users\\Administrator\\Desktop\\RPDM16_c2815C-G.xls','-t','C:\\Users\\Administrator\\Desktop\\BA1703060012.tsv']
    try:
        opts, args = getopt.getopt(sys.argv[1:], "x:t:", [''])
    except getopt.GetoptError:
        print '''
        program.py -t <varseq.tsv> -x <variantTable.xlsx> 
        '''
        sys.exit(1)

    variantTable,varseqTsv=None,None

    for key,value in opts:
        if key in ('-x'):
            variantTable=value
            continue
        if key in ('-t'):
            varseqTsv=value
            continue
    if not variantTable or not varseqTsv:
        sys.stderr.write('Please set variantTable.xlsx or varseq.tsv file')
        sys.exit()
    #  初始化读取文件，保留格式
    print time() + '  读取xls'
    xlsFile=xlrd.open_workbook(variantTable,formatting_info=True)
    oldSheet=xlsFile.sheets()[0]
    ## Tools for copying xlrd.Book objects to xlwt.Workbook objects.
    newXlsFile=copy(xlsFile)
    sheet=newXlsFile.get_sheet(0)



    print time() +'  开始'
    geneName,ntChange=getGeneAndNTChange(oldSheet)
    vMap=getVarseqMap(varseqTsv,geneName,ntChange)
    working(oldSheet,sheet,vMap)


    # 替换原来的文件
    print time() + '  结束'
    newXlsFile.save(variantTable)



if __name__=='__main__':
    main()



