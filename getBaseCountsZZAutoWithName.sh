#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

if [ $# -ne "2" ]; then
    echo "usage:: getBaseCountsZZAuto.sh OFILE BAM"
    exit
fi

OFILE=$1
BAM=$2

PDIR="/cbio/ski/chan/home/riazn/ref"
if [ ! -e $PDIR ]; then
	PDIR="/home/riazn/ref"
fi
CHR1TAG=$(samtools view -H $BAM | fgrep "@SQ" | head -1 | awk '{print $2"::"$3}')

if [ "$CHR1TAG" == "SN:chr1::LN:197195432" ]; then
	GENOME=/ifs/work/bio/assemblies/M.musculus/mm9/mm9.fasta
	SNPS=$SDIR/lib/ucsc_mm9_dbsnp128_NoDups.vcf.gz
elif [ "$CHR1TAG" == "SN:chr1::LN:249250621" ]; then
	GENOME=/ifs/work/bio/assemblies/H.sapiens/hg19/hg19.fasta
	SNPS=$SDIR/lib/dbsnp_137.hg19__RmDupsClean__plusPseudo50__DROP_SORT.vcf.gz
elif [ "$CHR1TAG" == "SN:1::LN:249250621" ]; then
	GENOME=$PDIR/b37.fasta
	#SNPS=$PDIR/dbsnp138.hg19.fixChr.noMito.vcf.gz
	SNPS=$PDIR/dbsnp142.b37_plusPseudo50.vcf.gz
elif [ "$CHR1TAG" == "SN:chr1::LN:248956422" ]; then
    # GRCh38 
	GENOME=$PDIR/GRCh38/GRCh38_full_analysis_set_plus_decoy_hla.fa
	SNPS=$PDIR/GRCh38/dbsnp144_GRCh38.noMito.chrFix.vcf.gz
else
	echo "INVALID GENOME"
	echo $CHR1TAG
	exit
fi

echo "Genome = " $GENOME
echo "SNP DB = " $SNPS

MINCOV=0
BASEQ=20
MAPQ=15

echo "GetBaseCount command: " $SDIR/bin/GetBaseCounts \
    --filter_improper_pair \
    --sort_output \
    --fasta $GENOME \
    --vcf $SNPS \
    --maq $MAPQ --baq $BASEQ --cov $MINCOV \
    --bam $BAM \
    --out $OFILE

$SDIR/bin/GetBaseCounts \
    --filter_improper_pair \
    --sort_output \
    --fasta $GENOME \
    --vcf $SNPS \
    --maq $MAPQ --baq $BASEQ --cov $MINCOV \
    --bam $BAM \
    --out $OFILE

gzip -9 $OFILE

