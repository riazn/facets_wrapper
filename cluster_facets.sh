#!/bin/bash
# Set default shell to bash
#$ -S /bin/bash
# Set default memory limits
#$ -l h_vmem=16G,virtual_free=16G

# Change directory to directory initiated in
#$ -cwd

# merge std error and std out into one file
#$ -j y

# email settings
#$ -m sae

#Job name
#$ -N facets_pipeline

# Read in bashrc
if [ -f ~/.bashrc ] ; then
    . ~/.bashrc
fi


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
