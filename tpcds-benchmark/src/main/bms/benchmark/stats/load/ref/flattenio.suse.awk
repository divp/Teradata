BEGIN {
#print "nodeid,date,time,ampm,avgcpu,user,nice,system,iowait,steal,idle,Device,rrqms,wrqms,rs,ws,rMBs,wMBs,avgrqsz,avgqusz,await,svctm,util"
}
{
if ($1 == "Linux") {
	nodeid=$3
	}
if (substr($1,7,2) == "12") {
   date = $1
   time = $2
   ampm= "AMPM"
   }
if ($1 == "avg-cpu:") {
	  getline
	  user   = $1
    nice   = $2
    sys    = $3
    iowait = $4
    steal  = $5
    idle   = $6
    }
if ($1 == "Device:") {
   getline
   getline
   getline
   getline
   getline
   getline
   printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", nodeid,date,time,ampm,user,nice,sys,iowait,steal,idle, $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
   getline
   printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", nodeid,date,time,ampm,user,nice,sys,iowait,steal,idle, $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
   getline
   printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", nodeid,date,time,ampm,user,nice,sys,iowait,steal,idle, $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
   getline
   printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", nodeid,date,time,ampm,user,nice,sys,iowait,steal,idle, $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
   }
}

