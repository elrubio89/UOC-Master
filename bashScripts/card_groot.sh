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

groot align -i grootIndex$seqlen -f $forward,$reverse -p 8 -g $sample-groot-graphs >$sample.bam
##generates bam file from both sequences
##Multiple FASTQ files can be specified as input
##however all are treated as the same sample and paired-end info isn’t used

samtools view -F 256 -h $sample.bam > $sample.sam
##Transform BAM file to SAM file (to execute python function).
##We have removed sequences with flag "not primary alignment" 

##################################################################
##Execute python function (path to python function must be added)
python groot_uniqseq.py $sample.sam
#####################################################################

##Continue with bash:

grep "\S" $sample-uniqseq.txt > $sample-uniqseq2.txt

mv -f $sample-uniqseq2.txt $sample-uniqseq.txt

cp $sample-uniqseq.txt $sample-uniqseq.sam
samtools view -S -b $sample-uniqseq.sam > $sample-uniqseq.bam

groot report -c 0 --bamFile $sample-uniqseq.bam >$sample-uniqseq-0report
groot report --bamFile $sample-uniqseq.bam >$sample-uniqseq-0.97report
groot report --bamFile $sample-uniqseq.bam --lowCov>$sample-uniqseq-lowCov-report
echo "Report: This will report gene, read count, gene length, coverage cigar"