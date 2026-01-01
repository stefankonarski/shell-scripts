#!/usr/bin/env sh
# Dump mysql databases via mysqldump and write
# each database in a single file
#
# @copyright 2012 Stefan Konarski
# @license BSD License
# @version 0.1
#

# Exclude the following databases
edb="information_schema performance_schema"

# Use this prefix for backup file names 
prefix="$(date +'%Y-%m-%d')_$(hostname)_"

# Use this suffix for backup file names
suffix=".sql"

# Compress backup files
pack=$(which bzip2)

dump=$(which mysqldump)
if [ ! -x $dump ]; then
    echo "$dump not executable"
    exit 1
fi

mysql=$(which mysql)
if [ ! -x $mysql ]; then
    echo "$mysql not executable"
    exit 1
fi

# Ask for password without prompt
stty -echo
read -p "Enter MySQL password for root: " pass; echo
stty echo

if [ "" = "$pass" ]; then
    echo "Login without password"
    dblogin='-u root'
else
    dblogin="-u root -p$pass"
fi

######################
# Execute backup     #
######################
out="$($mysql $dblogin -Bse 'show databases')"
# List for compressing files
fc=

# Loop over all databases
for db in $out
do
    # Don't skip any database as default
    skipdb=0
    # If excludable databases are defined
    if [ "$edb" != "" ]; then
        # Loop over excludable databases
        for n in $edb; do
            if [ "$db" = "$n" ]; then
                skipdb=1
                break;
            fi
        done
    fi

    if [ "$skipdb" = "1" ] ; then
        echo "Skip database $db"
        continue
    fi

    fn="./$prefix$db$suffix"
    echo "Dump database $db to $fn"
    $dump $dblogin --databases $db --result-file=$fn
    fc="$fc $fn"
done

######################
# Compress backups                   #
######################
if [ $pack ] && [ -x $pack ] && [ "$fc" != "" ]; then
    echo "Compress $fc"
    $pack $fc
fi

