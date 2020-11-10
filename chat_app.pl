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
my $port = 12345;
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

sub client {
    die "Couldn't Start the Chat Program: $!\n" unless defined($kpid = fork());

    if ($kpid) {
        clear();
        print("Connection established client, Please Chat!\n\n");

        while (defined($in = <$socket>)) {
            if ($in eq "/q\n") {  
                print("\nChat Ended\n\n");
                kill 1, $kpid;
                exit;
            } else {
                print("#$in"); 
            }
        }

        kill("TERM", $kpid); 
    }
    else {
        while (defined($out = <STDIN>)) {
            if ($out eq "/q\n"){
                print $socket "$out";
                print("\nChat Ended\n\n");;
                close $socket;
                kill 1, $kpid;
            } else {
                print $socket "$name: $out";
            }
        }
    }
}

sub server {
    my $server = IO::Socket::INET->new( 
        LocalAddr => $s,
        LocalPort => $port,
        Listen => 1,
        Reuse => 1
    );

    die "Could not create the chat session: $!\n" unless $server;

    clear();
    print("waiting for a connection on $port...\n\n");

    while ($socket = $server->accept()) {
        die "Can't fork: $!" unless defined($kpid = fork());

        if ($kpid) {
            clear();
            print("Connection established server, Please Chat!\n\n");

            while (defined($out = <STDIN>)) { 
                if ($out eq "/q\n") {
                    print $socket "$out";
                    print("\nChat Ended\n\n");
                    close $socket;
                    kill 1, $kpid;
                    exit;
                } else {
                    print $socket "$name: $out";
                }
            }
        } else {
            while (defined($in = <$socket>)) { 
                if ($in eq "/q\n") {
                    print("\nChat Ended\n\n");
                    close $socket;
                    kill 1, $kpid;
                    exit;
                } else {
                    print("#$in");
                }
            }
            close $socket;
            exit;
        }
        close $socket;
    }
}

$socket = IO::Socket::INET->new("$host:$port");

if ($socket) { 
    client();
} else {
    server();
}
