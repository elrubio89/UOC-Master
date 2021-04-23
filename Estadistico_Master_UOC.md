# Análisis estadístico de los reports obtenidos con GROOT/ARIBA/RGI

Tendremos:

- 10 muestras y para cada una:

  - Detección o no de un gen de resistencia con cada pipeline (categórico)

  - RPKM del gen de resistencia detectado con cada pipeline (cuantitativo): escalar estos valores para que sean comparables?

  - Secuencias mapeadas entre los 3 pipelines: nº de secuencias que coinciden. 

    

### Presencia/Ausencia

+ Diagrama de Venn de cada muestra: genes de resistencia detectados por una u otro pipeline. 

+ PCoA de matriz Presencia/Ausencia (1 y 0): Qué distancia utilizar?? + PERMANOVA +BiPlot

+ Chi-cuadrado/fisher de cada familia de gen de resistencia en función del pipeline

   

### Cuantitativo

+ Coeficiente de correlación entre los RPKM para cada familia de AMR escaldados de cada pipeline 2 a 2. 

+ PCoA: 10 muestras x 3 pipelines: ver si se agrupan por pipeline o por muestra

+ PERMANOVA del PCoA en función del pipeline (diferencia estadísticamente significativa)

+ BiPlot: ver que familia de AMR influye más en las diferencias???

+ Kurskal-Wallis de cada familia de gen de resistencia en función del pipeline