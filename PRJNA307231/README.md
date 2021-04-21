

# 10 samples: PRJNA307231





Paper: https://pubmed.ncbi.nlm.nih.gov/30171206/

### Select samples:

https://www.ncbi.nlm.nih.gov/bioproject/?term=PRJNA307231

+ Enter SRA experiments

+ SRA Run Selector:
  + Assay type: WGS (156 samples): download metadata file: `WGS_metadata.txt`



Select 5 samples VIH pos, 5 samples VIH neg and store in csv file: `samples_metadata.csv`

```bash
conda install -c bioconda sra-tools parallel fastqc multiqc
```

### Download fastq files

split files: sotres forward and reverse reads in separate files: 

```bash
mkdir fastq
cut -f 1 samples_metadata.csv | parallel --gnu "fastq-dump {} --split-files --outdir fastq/"
cd fastq
ls *fastq
SRR6714072_1.fastq  SRR6714074_1.fastq  SRR6714076_1.fastq  SRR6714078_1.fastq  SRR6714088_1.fastq
SRR6714072_2.fastq  SRR6714074_2.fastq  SRR6714076_2.fastq  SRR6714078_2.fastq  SRR6714088_2.fastq
SRR6714073_1.fastq  SRR6714075_1.fastq  SRR6714077_1.fastq  SRR6714079_1.fastq  SRR6714098_1.fastq
SRR6714073_2.fastq  SRR6714075_2.fastq  SRR6714077_2.fastq  SRR6714079_2.fastq  SRR6714098_2.fastq

```

### Quality analysis (fastqc)

```bash
mkdir fastqc
ls fastq/*.fastq | parallel --gnu "fastqc {} -o fastqc/"
cd fastqc
multiqc .
```

### Quality filter (fastp):

- q-: remove sequences with qualiti <=q20
- l-: minimum sequence length= 50 pb
- *-f: trim first 10 bp from each sequence*
- -c: enable base correction in overlapped regions (only for PE data), default is disabled


```bash
mkdir fastp
ls fastq/*.fastq  | sort | parallel --gnu --max-args=2 "fastp -i {1} -I {2} -o fastp/filt_{1} -O fastp/filt_{2} -q 20 -l 50 -c -f 10 -j fastp/{1/.}_fastp.json -h fastp/{1/.}_fastp.html"
```

https://opensource.com/article/18/5/gnu-parallel

Rename html and json files:

```bash
mmv \*_1_fastp.json \#1_fastp.json
mmv \*_1_fastp.html \#1_fastp.html
```

### Quality analysis after filtering (fastqc)

```bash
mkdir filt_fastqc
ls fastp/*.fastq | parallel --gnu "fastqc {} -o filt_fastqc/"
cd filt_fastqc
multiqc .
```

