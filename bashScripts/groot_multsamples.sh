#!/usr/bin/env bash

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
seqlen=$1

mkdir groot_analysis
cd groot_analysis

groot get -d card
##generates a folder called card.90 in working directory with clustered card database

groot index -m card.90 -i grootIndex$seqlen -w $seqlen -p 8
##Convert a set of clustered reference sequences to variation graphs and then index them


ls ../fastp/*.fastq  | sort | parallel --gnu --max-args=2 "groot align -i grootIndex$seqlen -f {1},{2} -p 8 -g {1/.}-groot-graphs > {1/.}.bam"
##generates bam file from samples and groot graph files

mmv \*_1\* \#1\#2 ##Rename bam files

ls *bam | parallel --gnu "samtools view -F 256 -h {} > {/.}.sam"
##Transform BAM file to SAM file (to execute python function).
##We have removed sequences with flag "not primary alignment"


ls *sam| parallel --gnu "python $MYDIR/../pythonScripts/groot_uniqseq.py {}" 
##Run python script on sam files
ls *-uniqseq.txt| parallel --gnu "grep "\S" {} > {/.}2.txt"
rm -f *-uniqseq.txt
##Remove empty lines

mmv \*-uniqseq2.txt \#1-uniqseq.sam ##Rename text files to sam files

ls *-uniqseq.sam | parallel --gnu "samtools view -S -b {} > {/.}.bam" ##Transform sam to bam files

ls *-uniqseq.bam | parallel --gnu "groot report -c 0 --bamFile {} > {/.}-0report "
ls *-uniqseq.bam | parallel --gnu "groot report --bamFile {} > {/.}-0.97report "
ls *-uniqseq.bam | parallel --gnu "groot report --bamFile {} --lowCov> {/.}-lowCov-report "

echo "Report: This will report gene, read count, gene length, coverage cigar"