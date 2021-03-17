#!/usr/bin/env bash
if [ $# -ne 2 ]
    then
        echo "usage: card_RGI.sh forward reverse (accepts fastq and fastq.gz formats)"
        echo "Downloads CARD database and aligns forward and reverse FASTQ reads using Bowtie2"
        exit
fi


##Volia afegir el comando: conda activate rgi pero em dona error


set -e

wget https://card.mcmaster.ca/latest/data ##generates data document
tar -xvf data ./card.json ##generates card.json in the current folder
rgi load --card_json card.json --local ##creates a folder called localdb

version=$(rgi database --version --local) ##obtain the card version we just downloaded

##This commands will generate: card_annotation.log and card_database_xx.fasta objects
rgi card_annotation -i card.json > card_annotation.log 2>&1
rgi load -i card.json --card_annotation card_database_v$version.fasta --local

echo "Downloaded card database version v$version"
echo "Aligning forward and reverse FASTQ reads using Bowtie2 against v$version CARD database"

forward=$1
reverse=$2

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


rgi bwt --read_one  $forward\
 --read_two $reverse\
 --aligner bowtie2\
 --output_file ${forward: -19:7}_RGI_output\
 --threads 8 --local

