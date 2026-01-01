#!/usr/bin/env
SRC=/host/foobar/local/data
DEST=/local/backup
NAME=backup
BACKUPS=11

# Exit if no source directory exists
if [ ! -d $SRC ]; then
  exit
fi

# Create backup directory if neccessary
if [ ! -d $DEST ]; then
  mkdir $DEST
fi

# Delete oldest backup directory
if [ -d $DEST/$NAME.$(($BACKUPS-1)) ];  then
   rm -rf $DEST/NAME.$(($BACKUPS-1))
fi

# Rotate backups
i=$(($BACKUPS-2))
while [ "$i" -ge "0" ]; do
   j=$(($i+1))
   if [ -d $DEST/$NAME.$i ]; then
     mv $DEST/$NAME.$i $DEST/$NAME.$j
   fi
   i=$(($i-1))
done

# Make next backup
rsync -a --delete --link-dest=$DEST/$NAME.1 $SRC $DEST/$NAME.0/