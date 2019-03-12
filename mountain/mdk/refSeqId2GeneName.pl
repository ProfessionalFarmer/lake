#!/bin/perl
# input a NM id
# https://www.biostars.org/p/73272/
use warnings;
use strict;
use Bio::Perl;
$| = 1;

my $db = new Bio::DB::RefSeq;

print "Input RefSeq ID: ";
my $refseq = <STDIN>;
chomp($refseq);

my $seq = get_sequence('refseq',$refseq);

# most of the time RefSeq_ID eq RefSeq acc
#my $seq = $db->get_Seq_by_id($refseq); # RefSeq ID
#print "accession is ", $seq->accession_number, "\n";

if ($seq->desc =~ /\((\w+)\)/) {
    print"found: $1\n";
        print $seq->desc;
        }
        else
        {
            print "defintion is ", $seq->desc, "\n";
            }


