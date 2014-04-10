#!/bin/bash

if [ $# -ne 1 ]
then
    "ERROR: Expecting path to DDL script as single argument"
    exit 1
fi    

script_path="$1"

bteq <<EOF
.LOGON 1700v3cop1/dbc,tdc1700;
DATABASE tpcds1000g;

$(cat "$script_path")

.LOGOFF;
.EXIT;
EOF
