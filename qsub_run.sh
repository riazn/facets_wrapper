#!/bin/bash
# walltime : maximum wall clock time (hh:mm:ss)
#PBS -l walltime=24:00:00
#
# do not join stdout and stderr
#PBS -j n
#
# spool output immediately
#PBS -k e
#
# specify queue
#PBS -q batch
#
# nodes: number of nodes
#   ppn: number of processes per node
#PBS -l nodes=1:ppn=1
#
# Memory
#PBS -l mem=16gb
#
echo "now here"	>> ~/test_out 
# export all my environment variables to the job
#PBS -V
#
# job name (default = name of script file)
#PBS -N facets
#
echo "now here"	>> ~/test_out 

echo "At Least made it here" > ~/junk
echo "test2" >> ~/junk

#SDIR="$( cd "$( dirname "$0" )" && pwd )"
export SDIR="/cbio/ski/chan/home/riazn/programs/FACETS.app"
if [ ! -e $SDIR ]; then
	export SDIR="/home/riazn/programs/FACETS.app"
fi

if [ -z $TUMORBAM ]; then
    echo "Must set TUMORBAM"
    exit 0;
fi

if [ -z $NORMALBAM ]; then
    echo "Must set NORMALBAM"
    exit 0;
fi

if [ -z $BAMDIR ]; then
    echo "Must set BAMDIR"
    exit 0;
fi

if [ -z $ODIR ]; then
    echo "Must set ODIR (output directory)"
    exit 0;
fi

#echo $SDIR
cd $ODIR
#echo ./run.sh $BAMDIR/$NORMALBAM $BAMDIR/$TUMORBAM 
$SDIR/run.sh $BAMDIR/$NORMALBAM $BAMDIR/$TUMORBAM > output/output_$NORMALBAM_$TUMORBAM
