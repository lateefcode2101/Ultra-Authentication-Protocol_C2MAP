# Define setting options
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             100                         ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(x)              500                        ;# X dimension of topography
set val(y)              500                        ;# Y dimension of topography 
set val(stop)           10                   ;# time of simulation end

set ns              [new Simulator]


#******Throughput****** 

set f0 [open Throughput.tr w] 

# *** Packet Deliverey Ratio *** 
 
set f1 [open Delay.tr w]

# *** Packet Delay Trace *** 
set f2 [open PDR.tr w] 
#Creating nam and trace file:
set f3 [open thrtimechaos.tr w] 
set s [open eff.tr w]
set tracefd       [open out.tr w]
set namtrace      [open out.nam w]   

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]

# configure the nodes
        $ns node-config -adhocRouting $val(rp) \
                   -llType $val(ll) \
                   -macType $val(mac) \
                   -ifqType $val(ifq) \
                   -ifqLen $val(ifqlen) \
                   -antType $val(ant) \
                   -propType $val(prop) \
                   -phyType $val(netif) \
                   -channelType $val(chan) \
                   -topoInstance $topo \
                   -agentTrace ON \
                   -routerTrace ON \
                   -macTrace OFF \
                   -movementTrace ON
for {set i 0} {$i < $val(nn) } { incr i } { 
set node_($i) [$ns node]	 
} 



# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 30 defines the node size for nam
$ns initial_node_pos $node_($i) 20
}

for {set i 0} {$i < $val(nn)} {incr i} {

$node_($i) set X_ [expr rand()*$val(x)]
$node_($i) set Y_ [expr rand()*$val(y)]
$node_($i) set Z_ 0

}
#Random mobility for all the nodes
for {set i 0} {$i < $val(nn)} {incr i} {

set xr [expr rand()*$val(x)]
set yr [expr rand()*$val(y)]

$ns at 0.0 "$node_($i) setdest $xr $yr 1"

}
$node_(14) color blue
$ns at 1.0 "$node_(14) color blue"
$node_(12) color blue
$ns at 1.0 "$node_(12) color blue"
$ns at 0.3 "$node_(14) label source"
$ns at 0.3 "$node_(12) label destination"


$ns at 0.0 "$ns trace-annotate \"Process started..............\""
$ns at 1.0 "$ns trace-annotate \" display source node and destination node.......\""
$ns at 1.1 "$ns trace-annotate \" Authenticaion is started using Chaos algorithm ....\""
$ns at 1.5 "$ns trace-annotate \" node A and node B generated keys and compare keys.....\""
$ns at 1.7 "$ns trace-annotate \" Session key generated...... \""
$ns at 1.8 "$ns trace-annotate \" data packets are transmitted with session key ...... \""

puts "\n\n "
puts "Enter the First Prime No m is "
flush stdout
set m [gets stdin]

puts "\n\n "
puts "Enter the Second Prime No f is "
flush stdout
set f [gets stdin]

puts "\n\n "
puts "Enter the PW is "
flush stdout
set PW [gets stdin]

puts "\n\n "
puts "Enter the node A id is "
flush stdout
set IDA [gets stdin]

puts "\n\n "
puts "Enter the node B id is "
flush stdout
set IDB [gets stdin]

puts "\n\n "
puts " Enter time stamp"
flush stdout
set T [gets stdin]

puts "\n\n "
set p [expr 90-$m]
set q [expr 90-$f]

set TM [expr (cos($m*$p)*$T)]
puts "TM value = $TM" 

set TM1 [expr int($TM) ]

set HA  [expr ($IDA|$IDB|$TM1|$PW|$T)]
puts "HA value =$HA"

set TF [expr (cos($f*$q)*$T)]
puts "TF value = $TF" 

   set TF1 [expr int($TF)] 
set HB  [expr $IDA|$IDB|$TM1|$PW|$T] 
puts "HB value=$HB"     
		   if {$HA == $HB}{
set HB1  [expr $IDA|$IDB|$TF1|$PW|$T]   
puts "HB1 value=$HB1" 
          set TFM [expr (cos($TF*$TM)*$T)]
          puts "\n\n "
          puts "session key value at node  B : $TFM"
                }
               
		set HA1  [expr $IDA|$IDB|$TF1|$PW|$T] 
        puts "HA1 value=$HA1"  
				   
                     if {$HA1 == $HB1} 
					 {                     
			set TMF [expr (cos($TM*$TF)*$T)]                         
                        puts "session key value at node A: $TMF "         
                     } 
					 else {
			puts "abort"
			}

                     if {$TMF== $TFM} {
                     puts "\n\n "

                        	 puts "Authentication Successfully"
                     } else {
                     		puts "abort"
			}

     
             
    
   $ns at 1.8 "$ns trace-annotate \" data packets are transmitted with session key $TFM ...... \""
   
  
  
$ns at 0.0 "record" 

set udp1 [new Agent/UDP]
$ns attach-agent $node_(14) $udp1
set sink0 [new Agent/LossMonitor]
$ns attach-agent $node_(12) $sink0
$ns connect $udp1 $sink0
$udp1 set fid_ 1
 

set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1024
$cbr1 set interval_ 0.09
$ns at 1.0 "$cbr1 start"
$ns at 10.0 "$cbr1 stop"



set holdtime 0 
set holdseq 0 
set holdrate 0

# Function To record Statistcis (Throughput, PDR, Delay) 

proc record {} { 

global sink0 f0 f1 f2 f3 s en holdtime holdseq holdrate
 
set ns [Simulator instance] 

set time 0.5 ;#Set Time  Interval 0.5 Sec 

set bw0 [$sink0 set bytes_]

set bw1 [$sink0 set lastPktTime_]

set bw2 [$sink0 set npkts_] 



set now [$ns now] 

set clock 1.7 
set type 2.5 
set maxdist 10


#Throughput

puts $f0 "$now [expr (($bw0+$holdrate)/8)/(2*$time)]"
 puts $f3 "[expr (($bw0+$holdrate)/8)/(2*$time)]" 

# Record Packet Delay in File 
if { $bw2 > $holdseq } { 
puts $f1 "$now [expr ($bw1 - $holdtime)/($bw2 - $holdseq)/$type]" 

} else { 
puts $f1 "$now [expr ($bw2 - $holdseq)]" 

} 

# PDR

	puts $f2 "$now [expr ($bw2/8)]"
	
	
 	$sink0 set bytes_ 0
	
 
$ns at [expr $now+$time] "record" ;# Schedule Record after $time interval sec 
} 








proc finish {} { 

    global ns tracefd namtrace f0 f1 f2 f3 s 

   $ns flush-trace 

	close $tracefd
	close $namtrace
	close $f0  
	close $f1
	close $f2
		close $f3
set a [open thrtimersaack.tr r]
set b [open thrtimechaos.tr r]
set time 1.0
set c 0.5
while {[gets $a line1] >= 0 && [gets $b line2] >= 0} {

    foreach a_line $line1 {
        foreach b_line $line2 {
 
            if {$a_line == $b_line } {
		puts $s "0"
            } else {
	puts $s "[expr (($b_line - $a_line)*100/$b_line)]"
   
       }

    }
 
}	
      

}


close $a
close $b
	close $s
	exec awk -f rout.awk out.tr > rout.tr & 
	exec xgraph Throughput.tr -geometry 800x400 -t "Throughput" -x "TIME" -y "bytes (pakts)" & 
	exec xgraph Throughputcomparision.tr  -geometry 700x300 -t "Throughput " -x "TIME" -y "bytes(pakts)"   &
	exec xgraph PDR.tr -geometry 800x400 -t "Packet Delivary Ratio" -x "TIME" -y "packet-delivery-ratio" & 
	exec xgraph PDRcomparision.tr  -geometry 700x300 -t "Packet Delivary Ratio " -x "TIME" -y "packet-delivery-ratio"   &
	exec xgraph Delay.tr -geometry 800x400 -t "End-to-End Delay" -x "TIME" -y "Delay(ms)" & 
	exec xgraph Delaycomparision.tr  -geometry 700x300 -t "End-to-End Delay " -x "TIME" -y "Delay(ms)"   &
	exec xgraph efficiency.tr -geometry 800x400 -t " % efficency" -x "TIME" -y "%efficiency" &
	exec nam out.nam & 
	exit 0 

} 

	
exec xgraph rout.tr  -geometry 800x400 -t "overhead" -x "TIME" -y "Bytes (pakts)" &
exec xgraph routcomparision.tr  -geometry 800x400 -t "overhead" -x "TIME" -y "Bytes (pakts)" &



for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$node_($i) reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run




