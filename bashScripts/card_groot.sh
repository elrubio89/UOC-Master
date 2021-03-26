#!/usr/bin/env bash

if [ $# -ne 3 ]
    then
    echo "usage: card_groot.sh forward reverse seqlen"
	echo "forward format: fastq"
	echo "reverse format: fastq"
    echo "short reads length from input sequences (numeric)"
    echo "Downloads CARD database and aligns forward and reverse FASTQ using GROOT pipeline"
    exit
fi
set -e

forward=$1
reverse=$2
filenamef=${forward##*/}
filenamer=${reverse##*/}
sample=${filenamef%_*}
seqlen=$3 ##short reads length


if [ ! -f $forward ]
then
    echo "File '$forward' not found! Cannot continue"
    exit 1
fi
if [ ! -f $reverse ]
then
    echo "File '$reverse' not found! Cannot continue"
    exit 1
fi

if [ $forward = $reverse ]
then
    echo "Same file provided for forwards and reverse reads. Cannot continue"
    exit 1
fi

mkdir groot_analysis
cd groot_analysis


groot get -d card
##generates a folder called card.90 in working directory with clustered card database

groot index -m card.90 -i grootIndex$seqlen -w $seqlen -p 8
##Convert a set of clustered reference sequences to variation graphs and then index them

groot align -i grootIndex$seqlen -f $forward,$reverse -p 8 -g $sample-groot-graphs >$sample-FR.bam
##generates bam file from both sequences
##Multiple FASTQ files can be specified as input
##however all are treated as the same sample and paired-end info isn’t used

groot report --bamFile $sample-FR.bam >$sample-report
groot report --bamFile $sample-FR.bam --lowCov>$sample-lowCov-report
echo "Report: This will report gene, read count, gene length, coverage cigar"