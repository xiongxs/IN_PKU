#! /usr/bin/perl -w
use strict;

sub mulit{
	my $a=$_[0];
	my $tmp=1;
	for(my $i=$a;;$i--){
		last if $i==0;
		$tmp=$tmp*$i;
	}
	return $tmp;
}

sub Ftest{
	my @list=@_;
	my $n=$list[0]+$list[1]+$list[2]+$list[3];
	my $p=(mulit($list[0]+$list[1])*mulit($list[2]+$list[3])*mulit($list[0]+$list[2])*mulit($list[1]+$list[3]))/(mulit($list[0])*mulit($list[1])*mulit($list[2])*mulit($list[3])*mulit($n));
	return $p;
}

my $test= Ftest(5,16,6,26);
print "$test\n";
