#!/usr/bin/env bash
if [ $# -ne 2 ]
    then
        echo "usage: fastp_filter.sh forward reverse (accepts fastq and fastq.gz formats)"
        echo "Filters paried-end sequences: Q20, min length 50 and base correction for"
        echo "overlapped regions is activated"
        exit
fi

set -e

forward=$1
reverse=$2
filenamef=${forward##*/}
filenamer=${reverse##*/}
sample=${filenamef%_*}

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

mkdir fastp_analysis
cd fastp_analysis

fastp -i $forward -I $reverse -o filtered2_$filenamef -O filtered2_$filenamer -q 20 -l 50 -c