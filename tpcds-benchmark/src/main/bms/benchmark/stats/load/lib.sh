#!/bin/bash

function get_query_result {
    query="$1"
    outfile=$(mktemp)
    
    bteq <<EOF 2>&1 > /dev/null
        .LOGON ${BMS_STATS_DB_HOST}/${BMS_STATS_DB_UID},${BMS_STATS_DB_PWD}
    
        .EXPORT FILE=$outfile;
        .SET SEPARATOR '|';
        .SET ECHOREQ OFF;
        .SET FORMAT OFF;
        
        $query
        .LOGOFF;
        .EXIT;
EOF

    sed -nr '3,${s/\s+//g;p}' $outfile
    rm $outfile
}

function run_sql {
    query="$1"
    
    bteq <<EOF
        .LOGON ${BMS_STATS_DB_HOST}/${BMS_STATS_DB_UID},${BMS_STATS_DB_PWD}
        
        $query
        .LOGOFF;
        .EXIT;
EOF
}

function normalize {
    file_name="$1"
    field_count=$2
    
    IOSTAT_FIELD_COUNT=15
    VMSTAT_FIELD_COUNT=20
    SAR_FIELD_COUNT=13

    # define constants for fixed point error rate calculations
    ERROR_RATE_MULTIPLIER=1000000 # 1 million (rate thus expressed in failures per million rows)
    MAX_ERROR_RATE=10000 # 10 thousand (max error rate is thus 10K errors per million rows = 0.01 = 1%)

    tmp_file="${file_name}.tmp"
    echo "Normalizing log file ${file_name}"
    SUMMARY_REPORT=/tmp/stats_summary.log
    echo "|NORM=" >> $SUMMARY_REPORT
    org_line_count=$(cat "${file_name}" | wc -l)
    if [[ $org_line_count -eq 0 ]]
    then
        echo "Original log contains zero lines"
        echo "{ORG=0}" >> $SUMMARY_REPORT
        return 1
    fi
    echo "Original line count: ${org_line_count}"
    echo "{ORG=${org_line_count}}" >> $SUMMARY_REPORT
    # back up original file
    cp ${file_name} ${file_name}.bak
    # remove duplicate lines
    #sort -u ${file_name}.bak > $file_name
    # Normalize line syntax
    # - remove tokens in angle brackets
    # - remove whitespace
    # - remove empty lines
    # - remove lines containing numerics with more than 7 integer digits before decimal point
    # - remove lines containing integers with 14 or more digits
    sed -ri 's/<.*>//g; s/\s//g; s/,,/,/g; /^$/d; /[0-9]{7,}\.[0-9]+/d; /[0-9]{14,}/d' $file_name
    
    # handle varying number of SAR fields
    if [[ $(basename "$file_name") =~ 'sarDEV' ]]
    then    
        # sar logs vary in number of fields due by (13 in SUSE, 12 in RHEL, difference is AM/PM indicator after time field)
        sar_field_count=$(sed -n '10p' "$file_name" | awk -F, '{print NF}')
        [[ -z $sar_field_count ]] && sar_field_count=0
        if [[ $sar_field_count -ne $(($SAR_FIELD_COUNT - 1)) && $sar_field_count -ne $SAR_FIELD_COUNT ]]
        then
            echo "SAR field count must be $(($SAR_FIELD_COUNT - 1)) (SLES) or $SAR_FIELD_COUNT (RedHat, CentOS); first line contains $sar_field_count fields"
            echo "{SAR_FC=ERROR}" >> $SUMMARY_REPORT
            return 1
        fi
        if [[ $sar_field_count -eq $(($SAR_FIELD_COUNT - 1)) ]]
        then
            # if only 12 fields are found, insert an empty field after 4th field to correct alignment
            mv "${LOCAL_LOG_DIR}/sarDEV_${RUN_ID}.log" "${LOCAL_LOG_DIR}/sarDEV_${RUN_ID}.log.bak"
            awk -F, '{print $1"," $2"," $3"," $4",," $5"," $6"," $7"," $8"," $9"," $10"," $11"," $12}' "${LOCAL_LOG_DIR}/sarDEV_${RUN_ID}.log.bak" > "${LOCAL_LOG_DIR}/sarDEV_${RUN_ID}.log"
        fi
    fi
        
    # filter out lines containing invalid number of fields
    awk -F, "NF==$field_count {print;}"  "$file_name" > $tmp_file
    mv $tmp_file $file_name
    final_line_count=$(cat "${file_name}" | wc -l)
    if [[ $final_line_count -eq 0 ]]
    then
        echo "Normalized log contains zero lines"
        echo "{FINAL=0}" >> $SUMMARY_REPORT
        return 1
    fi
    echo "{FINAL=${final_line_count}}" >> $SUMMARY_REPORT
    echo "Final line count: ${final_line_count}"
    invalid_line_count=$(( $org_line_count - $final_line_count ))
    echo "Invalid lines count: " $invalid_line_count
    echo "{INVALID_LC=${invalid_line_count}}" >> $SUMMARY_REPORT
    error_rate_per_million=$(( $invalid_line_count * $ERROR_RATE_MULTIPLIER  / $org_line_count ))
    echo "Error rate (per 1M lines): $error_rate_per_million"
    echo "{INVALID_ERATE=${error_rate_per_million}}" >> $SUMMARY_REPORT
    if [[ $error_rate_per_million -gt $MAX_ERROR_RATE ]] # fixed-point check for >1% error rate
    then
        echo "Error rate exceeds threshold ($MAX_ERROR_RATE)"
        echo "{INVALID_THRESHOLD_EXCEEDED}" >> $SUMMARY_REPORT    
        return 1
    fi
    
    #rm ${file_name}.bak
}
