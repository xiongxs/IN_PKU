#! /usr/bin/perl -w
use strict;

#my $rand=int(rand(12));
#print STDERR "$rand\n";

my $rand=0;
while(! $rand){
	$rand=int(rand(13));
	if( $rand==12 ||  $rand==0 || $rand==10 || $rand==11 || $rand==3){
		$rand=0;
		next;
	}
	print STDERR "For-group-1\t$rand\n";
}

$rand=0;
while(! $rand){
	$rand=int(rand(13));
	if( $rand==8 ||  $rand==0 || $rand==3 || $rand==11){
		$rand=0;
		next;
	}print STDERR "For-group-2\t$rand\n";
}



