#!/usr/bin/env bash
mkdir RGI_analysis
cd RGI_analysis

wget https://card.mcmaster.ca/latest/data ##generates data document
tar -xvf data ./card.json ##generates card.json in the current folder
rgi load --card_json card.json --local ##creates a folder called localdb

version=$(rgi database --version --local) ##obtain the card version we just downloaded

##This commands will generate: card_annotation.log and card_database_xx.fasta objects
rgi card_annotation -i card.json > card_annotation.log 2>&1
rgi load -i card.json --card_annotation card_database_v$version.fasta --local

echo "Downloaded card database version v$version"
echo "Aligning forward and reverse FASTQ reads using Bowtie2 against v$version CARD database"

ls ../fastp/*.fastq  | sort | parallel --gnu --max-args=2 -j 1 "rgi bwt --read_one  {1} --read_two {2}  --aligner bowtie2 --output_file {1/.} --threads 8 --local"
mmv \*_1\* \#1\#2 ##Rename files (Remove _1 ending from forward sequence names)

