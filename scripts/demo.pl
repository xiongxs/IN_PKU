#!/usr/bin/perl -w
use strict;

use threads;
use threads::shared;
use Term::ReadKey;
use Term::ANSIColor qw(:constants);

ReadMode ( 'cbreak' );


my $a :shared;
my $c :shared;
my $b :shared;
my $d :shared;

my $sig;

my $thr_1 = threads->create(\&threadA,);
my $thr_3 = threads->create(\&threadC,);
my $thr_2 = threads->create(\&threadB,);
my $thr_4 = threads->create(\&threadD,);

print "\nStarting 4 threads, press r to check threads status, press q to exit.\n\n";
while(1){
	$sig = ReadKey(0);

	if($sig eq 'q'){
		
		$thr_1->detach();
		$thr_3->detach();
		$thr_2->detach();
		$thr_4->detach();
		last;
	}
	if($sig eq 'r'){
		print "Thread_1 is reporting ";
		print RED "$a", RESET;
		print ".\n";
		print "Thread_2 is reporting ";
		print RED "$b", RESET;
		print ".\n";

		print "Thread_3 is reporting ";
		print RED "$c", RESET;
		print ".\n";
		print "Thread_4 is reporting ";
		print RED "$d", RESET;
		print ".\n";
		print "\n";
	}


}


ReadMode ( 'normal' );







####

sub threadA(){

	while(1){
		$a++;
		
	}

}


sub threadB(){
	while(1){
		$b++;
	}

}

sub threadC(){
	while(1){
		$c++;
	}

}

sub threadD(){
	while(1){
		$d++;
	}

}
