#!/usr/bin/perl -w
use strict;


my %ref;
my %read_count;
my $total_read = 0;
open IN,"samtools view -h $ARGV[0] | " or die $!;
while(<IN>){
	chomp;
	if (/^\@SQ/){
		my @a = split /\s+/,$_;
		$a[1] =~ /SN:(.*)/;
		my $chr = $1;
		$a[2] =~ /LN:(\d+)/;        ## Length of reference
		my $length = $1;
		$ref{$chr} = $length;
		next;
	}
	next if (/^\@RG/);
	my @a = split /\s+/,$_;
	my $chr = $a[2];
	next if ($chr eq "*");
	$read_count{$chr} ++;
	$total_read ++;
}
close IN;

open OUT,">$ARGV[-1]"  or die $!;
print OUT "Isoform\tLength\tMapped_reads\tRPKM\n";
foreach my $chr (sort keys %ref){
	if (exists $read_count{$chr}){
		my $rpkm = 10**9 * $read_count{$chr} / ($ref{$chr} * $total_read); 
		print OUT "$chr\t$ref{$chr}\t$read_count{$chr}\t$rpkm\n";
	}
	else {
		print OUT "$chr\t$ref{$chr}\t0\t0\n";
	}
}
