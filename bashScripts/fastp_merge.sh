#!/usr/bin/env bash
if [ $# -ne 2 ]
    then
        echo "usage: fastp_filter.sh forward reverse (accepts fastq and fastq.gz formats)"
        echo "Filters paried-end sequences according to fastp defalult parameters"
        echo "additionally generates merged files (default parameters"
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

fastp -i $forward -I $reverse -o filtered_$filenamef -O filtered_$filenamer -j fastp_filter.json -h fastp_filter.html
fastp -i $forward -I $reverse --merge --merged_out merged_$sample -o unmerged_$filenamef -O unmerged_$filenamer -j fastp_merge.json -h fastp_merge.html
