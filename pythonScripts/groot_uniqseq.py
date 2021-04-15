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