# NS-2 wired topology: two TCP/FTP flows and one UDP/CBR flow share a bottleneck.
# Run from this directory: ns tcp_udp_comparison.tcl
set ns [new Simulator]
set tracefile [open out.tr w]
set namfile [open out.nam w]
$ns trace-all $tracefile
$ns namtrace-all $namfile

set n0 [$ns node]; set n1 [$ns node]; set n2 [$ns node]
set n3 [$ns node]; set n4 [$ns node]; set n5 [$ns node]
$ns duplex-link $n0 $n2 10Mb 5ms DropTail
$ns duplex-link $n1 $n2 10Mb 5ms DropTail
$ns duplex-link $n2 $n3 1Mb 20ms DropTail
$ns duplex-link $n3 $n4 10Mb 5ms DropTail
$ns duplex-link $n3 $n5 10Mb 5ms DropTail
$ns queue-limit $n2 $n3 10

# TCP flow 0 -> 4
set tcp0 [new Agent/TCP]
$tcp0 set fid_ 1
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n4 $sink0
$ns connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

# TCP flow 1 -> 5
set tcp1 [new Agent/TCP]
$tcp1 set fid_ 2
$ns attach-agent $n1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n5 $sink1
$ns connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

# UDP CBR flow 0 -> 5
set udp0 [new Agent/UDP]
$udp0 set fid_ 3
$ns attach-agent $n0 $udp0
set null0 [new Agent/Null]
$ns attach-agent $n5 $null0
$ns connect $udp0 $null0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 1000
$cbr0 set interval_ 0.008
$cbr0 attach-agent $udp0

proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    puts "Simulation complete: out.tr and out.nam generated."
    exit 0
}
$ns at 0.5 "$ftp0 start"
$ns at 1.0 "$ftp1 start"
$ns at 1.5 "$cbr0 start"
$ns at 9.0 "$ftp0 stop"
$ns at 9.0 "$ftp1 stop"
$ns at 9.0 "$cbr0 stop"
$ns at 10.0 "finish"
$ns run
