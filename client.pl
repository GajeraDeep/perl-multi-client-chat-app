#!/usr/bin/perl -w

use strict;
use warnings FATAL => 'all';
use IO::Socket;
use Term::ANSIColor qw(:constants);

$SIG{CHLD} = 'IGNORE'; 

my $kpid;
my $in;
my $out;
my $host = "127.0.0.1";
my $port = 12000;
my $name;
my $socket;
my $s;

clear();

print("Please Enter your Screen Name...\n\nScreen Name: ");
$name = <STDIN>;
chomp $name;
clear();

sub clear {
    system('clear');
}

$socket = IO::Socket::INET->new("$host:$port");
die "Couldn't Start the Chat Program: $!\n" unless defined($socket);

die "Couldn't Start the Chat Program: $!\n" unless defined($kpid = fork());

if ($kpid) {
    clear();
    print("Connection established client, Please Chat!\n\n");

    while (defined($in = <$socket>)) {
        print("#$in"); 
    }

    kill("TERM", $kpid); 
}
else {
    while (defined($out = <STDIN>)) {
        if(not ($out =~ /^ *$/ or $out =~ /^\s*$/ or $out eq '')) {
            if ($out eq "/q\n"){
                print $socket "";

                print("\nBuy\n\n");;
                close $socket;
                kill 1, $kpid;
            } else {
                print $socket "$name: $out";
            }
        }        
    }
}
