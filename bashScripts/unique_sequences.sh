#!/usr/bin/env bash

bamfile=$1
filename=${bamfile##*/}
sample=${filename%\.*}
##Transform bamfile to samfile 
samtools view -h $bamfile > $sample.sam

while IFS= read -r line
do
    echo "Text read from file: $line"
done < $sample.sam



while read -r line
do
    ID=$(echo $line | cut -f1 -d ' ')
    status=$(echo $line | cut -f2 -d ' ')
    bamFile=${ID}.bam
    mapped=$(samtools view -c -F 4 $bamFile)
    proportion=$(echo "scale=10 ; $mapped / 10000000" | bc)
    printf "$status,$proportion\n" >> proportion-ARG-derived.csv
done < samples.txt