# -*- coding: utf-8 -*-
__author__ = 'Jason'
'''
Create   on: 20160203
Modified on:
Depend on information format from .stat file which is generated by snpAVStat.py
'''
import sys
import getopt
import ConfigParser
import matplotlib
matplotlib.use('Agg')

def getopts():
    try:
        options,args = getopt.getopt(sys.argv[1:],"i:o:",[''])
        return options
    except getopt.GetoptError:
        print '''
        program.py -i <INPUT> -o <OUTPUT>
        '''
        sys.exit()

def drawRegionPieChart(region_map,exonic_fucn_map,output):
    import matplotlib.pyplot as plt
    plt.style.use('ggplot')
    plt.rcParams['lines.linewidth'] = 0
    plt.rcParams['patch.linewidth'] = 0
    colors=['#2a5caa','#f58220','#00a6ac','#f15a22','#2585a6','#d93a49','#005344','#ffc20e','#ed1941','#2e3a1f','#444693','#1d953f','#cd9a5b','#1b315e','#596032','#63434f','#401c44','#dea32c','#54211d']
    fig = plt.figure(figsize=(20,8))
    ax1 = fig.add_subplot(1, 2, 1)
    ax2 = fig.add_subplot(1, 2, 2)

    rate = [region_map[key] for key in region_map.keys()]
    labels = [key for key in region_map.keys()]
    patches, texts = ax1.pie(rate,colors=colors[0:len(region_map.keys())])
    ax1.legend(patches, labels, bbox_to_anchor=(1.3, 0.9))
    ax1.set_title('')

    rate = [exonic_fucn_map[key] for key in exonic_fucn_map.keys()]
    labels = [key for key in exonic_fucn_map.keys()]
    patches, texts = ax2.pie(rate,colors=colors[0:len(region_map.keys())])
    ax2.legend(patches, labels, bbox_to_anchor=(1.25, 0.9))
    ax1.set_title('')

    plt.savefig(output,dpi = 500,bbox_inches='tight',format='png')
    plt.close()

def main():
    #sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\CHG004878_CHG004879.somatic.snp.ann.stat']
    input_path,outputh_path=None,None
    opts=getopts()
    for opt,value in opts:
        if 'i' in opt:
            input_path=value
            continue
        if 'o' in opt:
            outputh_path=value
            continue
    conf=ConfigParser.ConfigParser()
    conf.read(input_path)
    region_map={}
    exonic_fucn_map={}
    for key in conf.options('Region-based Annotation'):
        region_map[key]=int(conf.get('Region-based Annotation',key))
    for key in conf.options('Exonic Function Annotation'):
        exonic_fucn_map[key]=int(conf.get('Exonic Function Annotation',key))
    if not outputh_path:
        outputh_path=input_path+'.png'
    drawRegionPieChart(region_map,exonic_fucn_map,outputh_path)

if __name__=='__main__':
    main()

