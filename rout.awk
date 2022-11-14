BEGIN{
recvd = 0;#################### to calculate total number of data packets received
rt_pkts = 1;################## to calculate total number of routing packets received
gotime = 1;
time = 0;
packet_size = 1024;
time_interval=0.5;
}
#body
{
       event = $1
             time = $2
             node_id = $3
             level = $4
             pktType = $7

 if(time>gotime) {

  print gotime, (rt_pkts)*1;
  gotime+= time_interval;
  recv=0;
  }

##### Check if it is a data packet
if (( $1 == "r") && ( $7 == "cbr" || $7 =="tcp" ) && ( $4=="AGT" ))
{
 recvd++;
}

##### Check if it is a routing packet
if (($1 == "s" || $1 == "f") && $4 == "RTR" && ($7 =="AODV" || $7 =="message" || $7 =="DSR" || $7 =="OLSR")) 
{
rt_pkts++;
}

}
END {
;
}
