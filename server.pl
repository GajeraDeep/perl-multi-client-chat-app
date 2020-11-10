# use strict;
# use warnings FATAL => 'all';
use IO::Select; 
use IO::Socket;

$SIG{CHLD} = sub {wait ()}; 

$main_socket = IO::Socket::INET->new(
    LocalHost => '127.0.0.1', 
    LocalPort => 12000, 
    Listen => 5, 
    Proto => 'tcp', 
    Reuse => 1); 

die "Socket could not be created. Reason: $!\n" unless ($main_socket); 

$readable_handles = new IO::Select(); 
$readable_handles->add($main_socket); 

$writable_handles = new IO::Select(); 

while (1) { 
    ($new_readable, $writiable) = IO::Select->select($readable_handles, $writable_handles, undef, 0);

    foreach $sock (@$new_readable) { 
        if ($sock == $main_socket) { 
            $new_sock = $sock->accept(); 
            $readable_handles->add($new_sock); 
            $writable_handles->add($new_sock); 
        } else { 
            $buf = <$sock>; 
            if ($buf) { 
                print("$buf");

                foreach $w_sock (@$writiable) {
                    if($sock != $w_sock) {
                        print $w_sock $buf;
                    }
                }                
            } else { 
                $readable_handles->remove($sock); 
                $writable_handles->remove($sock); 
                close($sock); 
            } 
        } 
    } 

} 