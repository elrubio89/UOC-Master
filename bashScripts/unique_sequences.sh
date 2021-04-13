#!/usr/bin/env bash

bamfile=$1
file=$(samtools view $bamfile)
filename=${bamfile##*/}
sample=${filename%\.*}
##Transform bamfile to samfile 
samtools view $bamfile > $sample.txt

while read -r line
do
    qname=$(echo $line | cut -f1)
    printf "$qname\n" >> qname.txt
done < $sample.txt

while read -r line
do
    qname=$(echo $line | cut -f1 -d(\t))
    printf "$qname\n" >> qname.txt
done < filtered_RTC_149-FR.txt

while read -r line
do
    ID=$(echo $line | cut -f1 -d ' ')
    status=$(echo $line | cut -f2 -d ' ')
    bamFile=${ID}.bam
    mapped=$(samtools view -c -F 4 $bamFile)
    proportion=$(echo "scale=10 ; $mapped / 10000000" | bc)
    printf "$status,$proportion\n" >> proportion-ARG-derived.csv
done < samples.txt

while read -r line
do
    qname=$(echo $line | cut -f1 -d ' ')
    printf "$qname\n" >> cosa.txt
done < filtered_RTC_149-FR.txt


From python output:
grep "\S" filtered_RTC_149_uniqseq.txt > filtered_RTC_149_uniqseq2.txt
cp filtered_RTC_149_uniqseq2.txt filtered_RTC_149_uniqseq.sam
samtools view -S -b filtered_RTC_149_uniqseq.sam > filtered_RTC_149_uniqseq2.bam
samtools view filtered_RTC_149_uniqseq2.bam | cut -f1| sort | uniq | wc -l