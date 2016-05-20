#!/bin/bash

INNERANG=49.5
OUTERANG=200
RADPROFDIR="radprofs"
HAADFDIR="HAADF_image"
BEAMDIR="beam_pos"
BEAMPOSIN="beam_pos_corr2.out"
DATADIR="data"

mkdir -p $RADPROFDIR
mkdir -p $HAADFDIR
mkdir -p $HAADFDIR/$DATADIR

i=0
while read -r line
do
    XPOS[$i]=$(echo $line | awk '{print $1}')
    YPOS[$i]=$(echo $line | awk '{print $2}')
    if [ ${XPOS[$i]} -ne 0 ] && [ ${YPOS[$i]} -ne 0 ]; then
	i="$((i+1))"
    fi
done < "$BEAMPOSIN"

n=${#XPOS[@]}

for (( i=0; i<n; i++ )); do
    mkdir -p ${RADPROFDIR}/${BEAMDIR}_${XPOS[$i]}_${YPOS[$i]}/
done

while [ $(head HAADF_creator.ctl) -eq 0 ]; do
    ./radprof_eval.pl $BEAMPOSIN
    
    ./int_radprof_to_HAADF.pl $BEAMPOSIN $INNERANG $OUTERANG
    
    sleep 5h
done
