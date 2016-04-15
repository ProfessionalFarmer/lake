# -*- coding: utf-8 -*-
#! /usr/bin/python
__author__ = 'Jason'
'''
Create   on: 20160215
Modified on:
Sample order:  child, Father, mother
Index(0 Based):  9     10      11
'''
import getopt
import sys
import string
'''
来源可以分为五类（细分为7类），
来自母亲（00）、来自父亲（11）、来自父母（同时）（01）、
不确定（来自父亲或母亲）（10）和新生突变（22（纯新生）,20（母亲+新生）,21（父亲+新生））
'''
def getopts():
    try:
        options,args = getopt.getopt(sys.argv[1:],"i:o:",[''])
        return options
    except getopt.GetoptError:
        print '''
        program.py -i <INPUT> -o <OUTPUT>
        Support stdin and sdtout.
        '''
        sys.exit()


def judge(x,y,m,n,p,q):
    if y=='0':
        x,y=y,x # 0/X

    def code(g1,g2):
        if x=='0':
            return str(g2)
        else:
            return str(g1)+str(g2)

    fct=m+n # father combine temp
    mct=p+q
    oct=fct+mct # overall combine
    if x==y:
        if x in fct and y in mct:
            return code(1,2)
        if x not in fct and x in mct:
            return code(2,3)
        if x in fct and x not in mct:
            return code(1,3)
        if x not in fct and x not in mct:
            return code(3,3)
    elif x not in fct and y not in fct:
        if x not in mct and y not in mct:
            return code(3,3)
        if x in mct and y in mct:
            return code(3,4)
        if x+x==mct:
            return code(2,3)
        if y+y==mct:
            return code(3,2)
        if x in mct and y not in mct and (p!=x or q!=x):
            return code(2,3)
        if y in mct and x not in mct and (p!=y or q!=y):
            return code(3,2)
    elif x in fct and y in fct:
        if x not in mct and y not in mct:
            return code(1,3)
        if x in  mct and y in mct:
            return code(4,4)
        if x+x==mct:
            return code(2,1)
        if y+y==mct:
            return code(1,2)
        if x in mct and y not in mct and (p!=x or q!=x):
            return code(2,1)
        if y in mct and x not in mct and (p!=y or q!=y):
            return code(1,2)
    elif x+x==fct:
        if x not in mct and y not in mct:
            return code(1,3)
        if x in mct and y in mct:
            return code(1,2)
        if x+x==mct:
            return code(4,3)
        if y+y==mct:
            return code(1,2)
        if x in mct and y not in mct and (p!=x or q!=x):
            return code(1,3)
        if y in mct and x not in mct and (p!=y or q!=y):
            return code(1,2)
    elif y+y==fct:
        if x not in mct and y not in mct:
            return code(3,1)
        if x in mct and y in mct:
            return code(2,1)
        if x+x==mct:
            return code(2,1)
        if y+y==mct:
            return code(3,4)
        if x in mct and y not in mct and (p!=x or q!=x):
            return code(2,1)
        if y in mct and x not in mct and (p!=y or q!=y):
            return code(3,1)
    elif x in fct and y not in fct and (m!=x or n!=x):
        if x not in mct and y not in mct:
            return code(1,3)
        if x in mct and y in mct:
            return code(1,2)
        if x+x==mct:
            return code(2,3)
        if y+y==mct:
            return code(1,2)
        if x in mct and y not in mct and (p!=x or q!=x):
            return code(4,3)
        if y in mct and x not in mct and (p!=y or q!=y):
            return code(1,2)
    elif y in fct and x not in fct and (m!=y or n!=y):
        if x not in mct and y not in mct:
            return code(3,2)
        if x in mct and y in mct:
            return code(2,1)
        if x+x==mct:
            return code(2,1)
        if y+y==mct:
            return code(3,2)
        if x in mct and y not in mct and (p!=x or q!=x):
            return code(2,1)
        if y in mct and x not in mct and (p!=y or q!=y):
            return code(3,4)
    else: return '000'


def judgeVarSource(list,ofs):
    type_map={
        '2':'00',
        '1':'11',
        '12':'01',
        '21':'01',
        '4':'10',
        '44':'10',
        '3':'22',
        '33':'22',
        '31':'21',
        '13':'21',
        '32':'20',
        '23':'20',
        '34':'210',
        '43':'210',
        '000':'unkown'
    }
    num_type={}
    newList=[]

    for line in list:
        t=line.split('\t')
        chr=t[0]
        pos=t[1]
        id=t[2]
        ref=t[3]
        alt=t[4]

        altlist=[ref]
        altlist.extend(alt.split(','))

        gt=''
        x,y,m,n,p,q='0','0','0','0','0','0'
        if t[9]!='.':
            x= t[9].split(':')[0].split('/')[0]
            y= t[9].split(':')[0].split('/')[1]
        if t[10]!='.':
            m=t[10].split(':')[0].split('/')[0]
            n=t[10].split(':')[0].split('/')[1]
        if t[11]!='.':
            p=t[11].split(':')[0].split('/')[0]
            q=t[11].split(':')[0].split('/')[1]
        if x=='0' and y=='0':
            continue
	
	child_alt=''
        if x==y:
            gt='hom'
            child_alt=altlist[string.atoi(x)]
        else:
            gt='het'
            if y=='0':
                x,y=y,x
            if x!='0':
                child_alt=altlist[string.atoi(x)]+','
            child_alt=child_alt+altlist[string.atoi(y)]
        code=type_map[judge(x,y,m,n,p,q)]
        if code not in num_type.keys():
            num_type[code]=1
        else:
            num_type[code]=1+num_type[code]
        newList.append('%s\t%s\t%s\t%s\t%s\t%s\t%s\n' %(chr,pos,id,ref,child_alt,gt,code))

    ofs.write('##Code: Number\n')
    for key in num_type:
        ofs.write('# %s: %d\n' %(key,num_type[key]))

    ofs.write('##Chr\tPos\tid\tRef\tAlt\tGT\tType\n')
    for line in newList:
        ofs.write(line)


def main():
    #sys.argv=['','-i','C:\\Users\\Administrator\\Desktop\\out.vcf']
    opts=getopts()
    input,output=None,None
    ifs,ofs=None,None
    for key,value in opts:
        if key in ('-i'):
            input=value
            continue
        if key in ('-o'):
            output=value
            continue
    if input:
        ifs=open(input,'r')
    else:
        ifs=sys.stdin
    if output:
        ofs=open(output,'w')
    else:
        ofs=sys.stdout
    sys.stderr.write('Reading file.')
    list=[line.strip() for line in ifs if not line.startswith('#')]
    sys.stderr.write('..Done\n')
    judgeVarSource(list,ofs)
    ofs.flush()
    ofs.close()

if __name__=='__main__':
    main()

