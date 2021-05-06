#!/bin/bash

for stats in *stats.txt; do
    sample0=${stats%.*}
    sample=${sample0%.*}
    totalseq=$(grep ^Total $stats | sed s/[^0-9]//g)
    printf "$sample\t$totalseq\n" >> totalNumReads.csv; done


for stats in *stats.txt; do
    sample0=${stats%.*}
    sample1=${sample0%.*}
    sample=${sample1#*_}
    totalseq=$(grep ^Total $stats | sed s/[^0-9]//g)
    printf "$sample\t$totalseq\n" >> totalNumReads.csv; done
