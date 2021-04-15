# GROOT filter

El objetivo es quedarnos con sólo una entrada por QNAME del BAM file generado en el análisis de groot.  

```bash
samtools view filtered_RTC_149-FR.bam | cut -f1| sort | uniq | wc -l
4891 
```

1. Transformo el archivo BAM en SAM con samtools (incluyendo el header) y quitando las secuencias con FLAG: not primary alignment

   ```bash
   samtools view -F 256 -h filtered_RTC_149-FR.bam > filtered_RTC_149-FR.sam 
   ```

2. Ejecuto la función grootSAMfilter en python.

   Esta función está en el archivo: `UOC-Master/pythonScripts/groot_uniqseq.py`

   ```python
   import os
   def grootSAMfilter(samfile):
       file_name = os.path.basename(samfile)
       sample_name=file_name.split(".")[0]
       f=open(samfile) ##Abro el archivo SAM y se conveirte en una lista (lines)
       lines=f.readlines()
       f.close
       seq_unicas=[]#Lista vacía donde irán las secuecias únicas
       qnames=[] ##Lista vacía donde irán los qnames únicos
       for line in lines:
           campos=line.split("\t")
           qname=campos[0]    
           if line.startswith('@'): ##Añado header de samfile
               seq_unicas.append(line)
           elif qname not in qnames:
               qnames.append(qname)
               seq_unicas.append(line)
           else:
               pass
       with open (sample_name+'-uniqseq.txt', 'w') as out:
           for i in seq_unicas:
               out.write('%s\n' % i)
   
   import sys
   samfile=sys.argv[1]
   grootSAMfilter(samfile)
   ```
   
3. Modifico el archivo de texto generado por la función (elimino líneas en blanco): 

   ```bash
   grep "\S" filtered_RTC_149-FR_uniqseq.txt > filtered_RTC_149-FR_uniqseq2.txt
   ```

4. Transformo el archivo de texto en archivo SAM y luego en BAM con samtools: 

   ```bash
   cp filtered_RTC_149-FR_uniqseq2.txt filtered_RTC_149-FR_uniqseq.sam
   ```

   ```bash
   samtools view -S -b filtered_RTC_149-uniqseq.sam > filtered_RTC_149-FR_uniqseq.bam
   [samopen] SAM header is present: 2711 sequences.
   ```

5. Compruebo que el nº de secuencias del BAM file creado coincide con el nº de secuencias únicas del BAM file inicial: 

   ```bash
   samtools view filtered_RTC_149-uniqseq.bam | wc -l
   4891
   ```

Finalmente añado estas modificaciones al script

 `UOC-Master/bashScripts/card_groot.sh`

```bash
#!/usr/bin/env bash

if [ $# -ne 3 ]
    then
    echo "usage: card_groot.sh forward reverse seqlen"
	echo "forward format: fastq"
	echo "reverse format: fastq"
    echo "short reads length from input sequences (numeric)"
    echo "Downloads CARD database and aligns forward and reverse FASTQ using GROOT pipeline"
    exit
fi
set -e

forward=$1
reverse=$2
filenamef=${forward##*/}
filenamer=${reverse##*/}
sample=${filenamef%_*}
seqlen=$3 ##short reads length


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

mkdir groot_analysis
cd groot_analysis

groot get -d card
##generates a folder called card.90 in working directory with clustered card database

groot index -m card.90 -i grootIndex$seqlen -w $seqlen -p 8
##Convert a set of clustered reference sequences to variation graphs and then index them

groot align -i grootIndex$seqlen -f $forward,$reverse -p 8 -g $sample-groot-graphs >$sample.bam
##generates bam file from both sequences
##Multiple FASTQ files can be specified as input
##however all are treated as the same sample and paired-end info isn’t used

samtools view -F 256 -h $sample.bam > $sample.sam
##Transform BAM file to SAM file (to execute python function).
##We have removed sequences with flag "not primary alignment" 

##################################################################
##Execute python function (path to python function must be added)
python groot_uniqseq.py $sample.sam
#####################################################################

##Continue with bash:

grep "\S" $sample-uniqseq.txt > $sample-uniqseq2.txt

mv -f $sample-uniqseq2.txt $sample-uniqseq.txt

cp $sample-uniqseq.txt $sample-uniqseq.sam
samtools view -S -b $sample-uniqseq.sam > $sample-uniqseq.bam

groot report -c 0 --bamFile $sample-uniqseq.bam >$sample-uniqseq-0report
groot report --bamFile $sample-uniqseq.bam >$sample-uniqseq-0.97report
groot report --bamFile $sample-uniqseq.bam --lowCov>$sample-uniqseq-lowCov-report
echo "Report: This will report gene, read count, gene length, coverage cigar"
```

