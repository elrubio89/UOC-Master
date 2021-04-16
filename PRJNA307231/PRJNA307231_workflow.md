

# 10 samples

PRJNA307231

https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA307231

https://pubmed.ncbi.nlm.nih.gov/30171206/

Enter SRA experiments

SRA Run Selector:

​	Assay type: WGS (156 samples): download metadata file



Select 5 samples VIH pos, 5 samples VIH neg and store in csv file: `samples_metadata.csv`

```bash
conda install -c bioconda sra-tools parallel fastqc multiqc
```

Download fastq files 

```bash
cut -f 1 samples_metadata.csv | parallel --gnu "fastq-dump {}"
ls *fastq
SRR6714072.fastq  
SRR6714074.fastq  
SRR6714076.fastq  
SRR6714078.fastq  
SRR6714088.fastq
SRR6714073.fastq  
SRR6714075.fastq  
SRR6714077.fastq  
SRR6714079.fastq  
SRR6714098.fastq
```

Quality analysis (fastqc)

```bash
mkdir fastqc
ls *.fastq | parallel --gnu "fastqc {} -o fastqc/"
cd fastqc
multiqc .
```

Quality filter (fastp):

- q-: remove sequences with qualiti <=q20
- l-: minimum sequence length= 50 pb
- -f: trim first 10 bp from each sequence

```bash
cd ..
mkdir fastp
ls *.fastq | parallel --gnu "fastp -i {} -o fastp/filt_{}  -f 10 -q 20 -l 50 -j fastp/{/.}_fastp.json -h fastp/{/.}_fastp.html" 
```

