#!/usr/bin/env python
# -*- coding: utf-8 -*-
#######################################################################################
###                                                                                 ###
###     Copyright (C) 2019  Zhongxu ZHU, CityU, 20200925                            ###
###     Inspired by https://github.com/Jverma/GFF-Parser                            ###
###                                                                                 ###
#######################################################################################

####################################################################
# >>> from gtfParser import gtfParser
# >>> gtf = gtfParser(input_file)
#
# >>> gtf.getRecordsByID("TTN", "feature", "exon")
# >>> gtf.getRecordsByID("TTN", "transcript_id", "NM_001367552")
# >>> gtf.getRecordsByID(""NM_013416"", "feature", "start_codon")
# >>> gtf.getRecordsByID("NR_024540", "exon_id", "NR_024540.5")
import sys

class gtfParser:
    def __init__(self, input_file):
        self.data = {}
        self.dict = {}
        self.gene_attributes_dict = {} # ZZX
        self.transcriptID_geneID_dict = {} # ZZX

        sys.stderr.write("#####################\nParsing reference gtf file: " +
                         input_file +
                         '\n#####################\n')

        for line in open(input_file):
            if line.startswith("#"): continue
            record = line.strip().split("\t")
            sequence_name = record[0]
            source = record[1]
            feature = record[2]
            start = int(record[3])
            end = int(record[4])
            if (record[5] != '.'):
                score = record[5]
            else:
                score = None
            strand = record[6]
            if (record[7] != '.'):
                frame = record[7]
            else:
                frame = None
            attributes = record[8].split(';') # please note the separator between each attribute
            attributes = [x.strip() for x in attributes[0:-1]] # ZZX
            attributes = {x.split(' ')[0]: x.split(' ')[1].strip("\"") for x in attributes if " " in x} # ZZX

            if not (sequence_name in self.data): self.data[sequence_name] = []
            alpha = {'source': source, 'feature': feature, 'start': start, 'end': end, 'score': score, 'strand': strand,
                     'frame': frame}
            # python 3 .items(), python 2 .iteritems() ZZX
            for k, v in attributes.items(): alpha[k] = v
            self.data[sequence_name].append(alpha)

        # ZZX
        for k, v in self.data.items():
            for alpha in v:
                gene_id = alpha["gene_id"]
                transcript_id = alpha["transcript_id"]

                self.transcriptID_geneID_dict[transcript_id] = gene_id
                if gene_id in self.gene_attributes_dict.keys():
                    self.gene_attributes_dict[gene_id].append(alpha)
                else:
                    self.gene_attributes_dict[gene_id] = list()
                    self.gene_attributes_dict[gene_id].append(alpha)


    def getRecordsByID(self, id, attType, attValue):
        """
        Gets all the features for a given gene


        :param id: Identifier of the gene (specified by gene_id) or mRNA (specified by transcript_id)
        :param attType: Any attribute list in gtf file.
        :param attValue:
        :return: A list of features related to ID where restricted by attType and attValue.
        """

        att_list = []
        if id in self.gene_attributes_dict.keys():
            for x in self.gene_attributes_dict[id]:
                if ( attType in x.keys() and  x[attType] == attValue ):
                    att_info = x
                    att_list.append(att_info)
        elif id in self.transcriptID_geneID_dict.keys():
            for x in self.gene_attributes_dict[self.transcriptID_geneID_dict[id]]:
                if ( attType in x.keys() and  x[attType] == attValue and x["transcript_id"] == id):
                    att_info = x
                    att_list.append(att_info)
        else:
            sys.stderr.write("Could not find ID "+id+'\n')
            sys.exit(1)
        return att_list
