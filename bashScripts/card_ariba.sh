#!/usr/bin/env bash

if [ $# -ne 2 ]
    then
        echo "usage: card_ariba.sh forward reverse"
	    echo "forward format: fastq or fastq.gz"
	    echo "reverse format: fastq or fastq.gz"
        echo "Downloads CARD database and aligns forward and reverse FASTQ using ARIBA pipeline"
        exit
fi

forward=$1
reverse=$2
filename_f=${forward##*/}
filename_r=${reverse##*/}
sample=${filename%_*}

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

mkdir ariba_analysis
cd ariba_analysis

ariba getref card out.card ##generates files out.card.fa out.card.log out.card.tsv in current directory
ariba prepareref -f out.card.fa -m out.card.tsv ariba_db ##generates folder ariba_db

ariba run ariba_db $forward $reverse ${sample}_ariba_results ##stores results in ariba_results folder