#! /usr/bin/perl -w
use strict;

sub mid{
	my @list = sort{$a<=>$b} @_;
	my $count = @list;
	if( $count == 0 )
	{
		return undef;
	}   
	if(($count%2)==1){
		return $list[int(($count-1)/2)];
	}
	elsif(($count%2)==0){
		return ($list[int(($count-1)/2)]+$list[int(($count)/2)])/2;
	}
}

sub avg{
	my $count=@_;
	my $total=0;
	foreach my $ab(@_){
		$total+=$ab;
	}
	return $total/$count;
}

open IN,$ARGV[0] or die $!;
open IN2,$ARGV[1] or die $!;



