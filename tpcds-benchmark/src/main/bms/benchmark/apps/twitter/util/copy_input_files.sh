f_local=$(ls -l /data/twitter/*.log | awk '{print $9 "@" $5;}' | sort)
f_remote=$(ssh asterdc "ls -l /data02/twitter/*.log" | awk '{print $9 "@" $5;}' | sort)

for f in $f_remote
do
    fname=$(basename ${f%@*})
    fsize=${f#*@}
    found=0
    download=0
    echo -ne "Remote file $fname: "
    for f1 in $f_local
    do
        f1name=$(basename ${f1%@*})
        f1size=${f1#*@}
        if [[ $fname == $f1name ]]
        then
            echo -ne "found in local"
            if [[ $fsize -eq $f1size ]]
            then
                found=1
                echo -ne " - size OK ($fsize)\n"
            else
                echo -ne " - size mismatch ($fsize vs $f1size)\n"
                download=1
            fi
        fi
    done
    if [[ $found -eq 0 ]]
    then
        echo -ne "not found in local\n"
        download=1
    fi
    if [[ $download -eq 1 ]]
    then
        echo "Downloading $fname"
        scp asterdc:/data02/twitter/$fname /data/twitter
    fi
done

