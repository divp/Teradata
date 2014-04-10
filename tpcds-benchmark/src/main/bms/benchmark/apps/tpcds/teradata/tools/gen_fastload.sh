#!/bin/bash

# Generate fastload scripts from live data dictionary definitions

set -o nounset
set -o errexit

# Must source exports.sh in order to export global parameters defined in test properties
. $BENCHMARK_PATH/exports.sh
. $BENCHMARK_PATH/lib/lib.sh

bteq_output=$(mktemp)

INPUT_FILE=someinputfile.dat
TABLE_NAME=item

# Get column list from catalog
bteq <<EOF > $bteq_output
.LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
DATABASE ${BMS_TERADATA_DBNAME_ETL1};

select columnname from dbc.columns where tablename='${TABLE_NAME}';

.LOGOFF;
.EXIT;
EOF

out_script=$(mktemp)

cat <<EOF >>$out_script
    
    .LOGON ${BMS_TERADATA_DB_HOST}/${BMS_TERADATA_DB_UID},${BMS_TERADATA_DB_PWD};
    DATABASE ${BMS_TERADATA_DBNAME_ETL1};
    
    ERRLIMIT 1;

    SET RECORD VARTEXT '|';
    DEFINE
EOF

#        in_tstamp_epoch (VARCHAR(30))
#        ,in_x0 (VARCHAR(30))
#    ...
#    FILE=$INPUT_FILE;
#
#    SHOW;
#
#    BEGIN LOADING benchmark.stage_vmstat ERRORFILES benchmark.ERR1, benchmark.ERR2;
#
#    INSERT INTO benchmark.stage_vmstat VALUES (
#    :in_tstamp_epoch
#    ,:in_x0
#    ...
#    );
#
#    END LOADING;
#    LOGOFF;
#EOF

columns_list=$(mktemp)
# Parse bteq output and extract column information
state=0
# Use state machine to select column names out of BTEQ output
while read line
do
    if [[ $state -eq 0 ]] && [[ $line == 'ColumnName' ]]
    then
        state=1
        continue
    fi
    if [[ $state -eq 1 ]] && [[ $line =~ --* ]]
    then
        state=2
        continue
    fi
    if [[ $state -eq 2 ]] 
    then
        if [[ $line =~ ^$ ]]
        then
            break
        else
            echo $line
        fi
    fi
done <$bteq_output >>$columns_list


out_script=$(mktemp)

cat <<EOF >>$out_script
    SET RECORD VARTEXT '|';
    DEFINE
EOF

count=0
column_count=$(cat $columns_list | wc -l)
while read column
do
    count=$(( $count + 1 ))
    echo -n "        $column (VARCHAR(200))"
    if [ $count -lt $column_count ]
    then
        echo ','
    else
        echo
    fi
done < $columns_list >>$out_script

cat <<EOF >>$out_script
    FILE=$INPUT_FILE;

    SHOW;

    BEGIN LOADING ${TABLE_NAME} ERRORFILES FASTLOAD_ERR1, FASTLOAD_ERR2;
    
    INSERT INTO ${TABLE_NAME} VALUES (
EOF

count=0
column_count=$(cat $columns_list | wc -l)
while read column
do
    count=$(( $count + 1 ))
    echo -n "        :in_${column}"
    if [ $count -lt $column_count ]
    then
        echo ','
    else
        echo
    fi
done < $columns_list >>$out_script

cat <<EOF >>$out_script
    );
    
    END LOADING;
    LOGOFF;
EOF

rm $bteq_output
rm $columns_list

cat $out_script
