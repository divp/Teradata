{
if ($1 == "Linux") {
        nodeid=$3
        date=$4
        }
else
if ($3 == "IFACE") {
   }
else
if (length($0) > 1) {
if ($3 == "bond0") {
      printf("%s,%s,%s,AMPM,%s,%s,%s,%s,%s,%s,%s,%s\n",nodeid,date,$1,$2,$3,$4,$5,$6,$7,$8,$9)
      }
   }
}

