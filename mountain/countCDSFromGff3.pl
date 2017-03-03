#!/usr/bin perl

# perl count_CDS.pl annotation.gff3
my %genes;
while(<>) {
 chomp;
 my @row = split(/\t/,$_);
 next unless  $row[2] eq 'CDS';
 my %group = map { split(/=/,$_) } split(/;/,pop @row);
 $genes{$group{Parent}}++;
}

#sorted by genes with the most number of CDS to least, though you could just sort by ID too
for my $gene  ( sort { $genes{$b} <=> $genes{$a} } keys %genes ) {
 print join("\t",$gene, $genes{$gene}), "\n";
}


