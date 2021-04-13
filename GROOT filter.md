# GROOT filter

El objetivo es quedarnos con sólo una entrada por QNAME del BAM file generado en el análisis de groot.  

```bash
samtools view filtered_RTC_149-FR.bam | cut -f1| sort | uniq | wc -l
4891 
```

1. Transformo el archivo BAM en SAM con samtools (incluyendo el header)

   ```bash
   samtools view -h filtered_RTC_149-FR.bam > filtered_RTC_149-FR.sam 
   ```

2. Ejecuto la función grootSAMfilter en python.

   Esta función está en el archivo: `UOC-Master/bashScripts/groot_uniqseq.py`

   ```python
   import os
   def grootSAMfilter(samfile):
       file_name = os.path.basename(samfile)
       sample_name=file_name.split(".")[0]
       f=open(samfile)
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
       with open (sample_name+'_uniqseq.txt', 'w') as out:
           for i in seq_unicas:
               out.write('%s\n' % i)
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
   samtools view -S -b filtered_RTC_149-FR_uniqseq.sam > filtered_RTC_149-FR_uniqseq.sam
   [samopen] SAM header is present: 2711 sequences.
   ```

5. Compruebo que el nº de secuencias del BAM file creado coincide con el nº de secuencias únicas del BAM file inicial: 

   ```bash
   samtools view filtered_RTC_149-FR_uniqseq.bam | wc -l
   4891
   ```

   