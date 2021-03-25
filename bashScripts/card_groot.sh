#!/usr/bin/env bash

if [ $# -ne 2 ]
    then
        echo "usage: card_ariba.sh forward reverse"
	echo "forward format: fastq or fastq.gz"
	echo "reverse format: fastq or fastq.gz"
        echo "Downloads CARD database and aligns forward and reverse FASTQ using ARIBA pipeline"
        exit
fi

