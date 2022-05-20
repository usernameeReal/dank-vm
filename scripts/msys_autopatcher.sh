#!/bin/bash
if [ $OS == "Windows_NT" ]; then
INSRC=$(cat scripts/autopatch.in)
INSRC=${INSRC//"[PREFIX]"/$MINGW_PREFIX}
echo $INSRC | sed -e 's/\[NEWLINE\]/\n/g' | sed -e 's/\[DSPACE\]/  /g' | sed -e 's/\[CHANGE\]/! /g' | sed -e 's/\[STAR\]/\*/g' | sed -e 's/\[SPACE\]/ /g' | sed 's/.$//' | patch -p0 -d/
echo "You may now build collab-vm-server using make."
else
echo "You do not need to run this file. Please continue to build collab-vm-server using make."
fi