fastload <<EOF

LOGON localhost/dbc,dbc;

BEGIN LOADING benchmark.stage_sarstat ERRORFILES benchmark.ERR1, benchmark.ERR2;
END LOADING;
LOGOFF;
EOF


