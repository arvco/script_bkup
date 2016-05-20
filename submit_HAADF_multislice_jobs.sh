#!/bin/bash

NOLDSNAP=$1
NSNAPS=$2
NLINES=$3
SNAPFILIN="/home/p/paul/pfs/lammps_runs/SrTiO3/cl_md/300K/production/pure_NVT/strontium_titanate.snaps"
ROOTDIR=$(pwd)
SNAPDIR="snapshots"
SNAPOUT="snapshot"
MULTEXE="/home/p/paul/pfs/build/Multislice_v10/multislice_v10"
BEAMPOSIN="beam_pos.out"
MULTIN="SrTiO3_HAADF_mult_tpl.in"
BATCHFILE="SrTiO3_HAADF_mult_tpl.sbatch"
TMPSNAPFIL="lammps.snap.tmp"
NPREVLINE=1
CONTROL=0
# Number of multislice grid points in x and y direction per beam position
GRIDXPERPOS=5
GRIDYPERPOS=5
# Take every SNAPMULT snapshot for the multislice calculation
SNAPMULT=3
# First snapshot to be used for multislice
NSTARTSNAP=72
NENDSNAP=162
NJOB=2000


# Get X and Y beam position
i=0
while read -r line
do
    XPOS[$i]=$(echo $line | awk '{print $1}')
    YPOS[$i]=$(echo $line | awk '{print $2}')
    i="$((i+1))"
done < "$BEAMPOSIN"

NPOS=${#XPOS[@]}

mkdir -p $SNAPDIR
cd $SNAPDIR

for (( i=0; i<=$NSNAPS; i++ )); do
    mkdir -p ${SNAPOUT}_$i
done

while [ $CONTROL -eq 0 ]; do
    
    NCURRLINE=$(wc -l < $SNAPFILIN)
    NCURRSNAP=$(expr $(expr $NCURRLINE - $NPREVLINE + 1) / $NLINES)
    echo $NCURRLINE $NPREVLINE
    
    if [ $NCURRSNAP -gt $NOLDSNAP ]; then
	sed -n $NPREVLINE','$NCURRLINE'p' $SNAPFILIN > $TMPSNAPFIL
	
	if [ $NCURRSNAP -gt $NSNAPS ]; then
	    CONTROL=1
	    NCURRSNAP=$(expr $NSNAPS + 1)
	fi
	
	echo $NCURRSNAP $NOLDSNAP
	$ROOTDIR/snapper.pl $TMPSNAPFIL $(expr $NCURRSNAP - 1) $NLINES $SNAPOUT
	rm lammps.snap.tmp
	
	for (( b=$NOLDSNAP; b<$NCURRSNAP; b++ )); do
	    cd ${SNAPOUT}_$b
	    echo $(pwd)
	    
	    for (( c=0; c<NPOS; c++ )); do
		
		if [ ${XPOS[$c]} -ne 0 ] && [ ${YPOS[$c]} -ne 0 ]; then
		    mkdir -p beam_pos_${XPOS[$c]}_${YPOS[$c]}

		    if [ $b -eq $(expr $b / $SNAPMULT \* $SNAPMULT) ] && [ $b -ge $NSTARTSNAP ] && [ $b -le $NENDSNAP ]; then
			cp fort.20 $MULTEXE beam_pos_${XPOS[$c]}_${YPOS[$c]}/
			
			cd beam_pos_${XPOS[$c]}_${YPOS[$c]}
			sed 's/<BEAMX>/'$(expr ${XPOS[$c]} \* $GRIDXPERPOS - $GRIDXPERPOS )'/' ../../../$MULTIN > ${XPOS[$c]}_${YPOS[$c]}_${MULTIN}
			sed -i 's/<BEAMY>/'$(expr ${YPOS[$c]} \* $GRIDYPERPOS - $GRIDYPERPOS )'/' ${XPOS[$c]}_${YPOS[$c]}_${MULTIN}
			
			sed 's/<MULTISLICEIN>/'${XPOS[$c]}_${YPOS[$c]}_${MULTIN}'/' ../../../$BATCHFILE > ${XPOS[$c]}_${YPOS[$c]}_${b}_$BATCHFILE
			sed -i 's|<EXECUTABLE>|./multislice_v10|' ${XPOS[$c]}_${YPOS[$c]}_${b}_$BATCHFILE
			
			while [ $(squeue -u paul | wc -l ) -ge $NJOB ]; do
			    sleep 10m
			done
			
			sbatch ${XPOS[$c]}_${YPOS[$c]}_${b}_$BATCHFILE
			cd $ROOTDIR/$SNAPDIR/${SNAPOUT}_$b
		    fi
		    
		else
		    continue
		fi
	    done
	    cd $ROOTDIR/$SNAPDIR
	done
			
	NOLDSNAP=$NCURRSNAP
	NPREVLINE=$NCURRLINE
	
    elif [ $NCURRSNAP -eq $NSNAPS ]; then
	CONTROL=1
    else
	sleep 10m
    fi
    
done

cd $ROOTDIR

