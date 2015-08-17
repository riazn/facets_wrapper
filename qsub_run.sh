#!/bin/sh

#SDIR="$( cd "$( dirname "$0" )" && pwd )"
SDIR="/cbio/ski/chan/home/riazn/programs/FACETS.app"
if [ ! -e $SDIR ]; then
	SDIR="/home/riazn/programs/FACETS.app"
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

echo $SDIR
cd $ODIR
#echo ./run.sh $BAMDIR/$NORMALBAM $BAMDIR/$TUMORBAM 
$SDIR/run.sh $BAMDIR/$NORMALBAM $BAMDIR/$TUMORBAM > output/output_$NORMALBAM_$TUMORBAM
