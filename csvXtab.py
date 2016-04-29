#! /usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'Jason'
# Create: 20160114
# Modified on: 20160115, 20160118 fix bug, 20160119 read csv file by csv module, 20160421 fix a bug
# Simple python script that convert csv to tab (-c or --csv option) or convert tab to csv (-t or --tab option).
# Support stdin and stdout

from optparse import OptionParser
import sys
import csv
import types

def getOptions():
    parser = OptionParser(usage="%prog -i <INPUT> -[csv|tab] [-o OUT]", version="%prog 1.0")
    parser.add_option("-i",     "--input",     type="string",   dest="input",   action="store",   help="Input file. File should be seperated by tab or comma. If not specify, use stdin", metavar="file")
    parser.add_option("-o",     "--output",    type="string",   dest="output",  action="store",   help="Output file path. If not specify, use stdout.", metavar="file")
    parser.add_option("-t",     "--tab",     default=False,       dest="tab",  action="store_true", help="Line field is tab splitted" )
    parser.add_option("-c",     "--csv",     default=True,        dest="csv",  action="store_true", help="Line field is ',' splitted. Default True.")
    (options, args) = parser.parse_args()
    return options

def readLine(path,isExsitCSVFile):
    """
    Yeild a line for processing.
    :param path: Input file path. If path not specified, use stdin instead. If input csv exsits, csv module will be invoked to read csv file
    :return: line string or list
    """
    if path:
        if isExsitCSVFile:
            reader = csv.reader(open(path, 'rb'))
            for line in reader:
                yield line
    for line in csv.reader(sys.stdin):
        yield line

def csv2tab(line):
    """
    Just simplely convert csv to tab. Do not concert csv format with complex condition
    :param line: If line has been splitted by csv module, just return directly.
    :return: 
    """
    if type(line) is types.ListType:
        return '\t'.join(line)+'\n'
    line=line.replace(',"','"').replace('",','"')
    t=line.split('"')#if , is enclosed by " , then , in odd number
    newt=[]
    if len(t) <=2 :
        return line.replace(',','\t')
    else:
        for i,e in enumerate(t):
            if i%2==1:
                newt.append(e)
            else:
		if e=='': continue
                newt.extend(e.split(','))
    return '\t'.join(newt)

def tab2csv(line):
    temp=[]
    for t in line.split('\t'):
        if ',' in t:
            temp.append('"%s"' % t) # if comma in field, use double quotation marks to enclose comma
        else:
            temp.append(t)
    return ','.join(temp)

def main():
    #sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\t.csv']
    options=getOptions()
    isExsitCSVFile=False

    if options.output:
        out=open(options.output,'w')
    else: out=sys.stdout # if output path not specified, use stdout instead
    if options.input and not options.tab:
        isExsitCSVFile=True
    for line in readLine(options.input,isExsitCSVFile):
        if options.tab:
            newLine=tab2csv(line)
        else:
            newLine=csv2tab(line)
        out.write(newLine)
    out.flush()
    out.close()

if __name__=='__main__':
    main()


