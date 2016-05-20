#!/bin/bash

TIME=$SECONDS
PARDIR=$(pwd)
NHEAD=9
NATOMS=115200
NSNAPS=$1
SNAPDIR=$2
SNAPIN=$3
SNAPOUT=$4

mkdir -p $SNAPDIR
#cp $SNAPIN $SNAPDIR
cd $SNAPDIR

for (( i=0; i<=$NSNAPS; i++ )); do
    mkdir -p $SNAPOUT"_$i"    
done

../snapper.pl ../$SNAPIN $NSNAPS $(expr $NATOMS + $NHEAD) $SNAPOUT


