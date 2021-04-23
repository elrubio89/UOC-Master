#!/usr/bin/env bash
mkdir ariba_analysis
cd ariba_analysis

ariba getref card out.card ##generates files out.card.fa out.card.log out.card.tsv in current directory
ariba prepareref -f out.card.fa -m out.card.tsv ariba_db ##generates folder ariba_db

ls ../fastp/*.fastq  | sort | parallel --gnu --max-args=2 "ariba run ariba_db {1} {2} {1/.}_ariba_results"

prename 's/_1_/_/' *_1_*/ ##Change folder names (Substitute _1_ for _)

##Change report names to include sample name and move them from the directories
for subdir in filt*; do
    subdir1=${subdir%_*}
    subdir2=${subdir1%_*}
    mv $subdir/report.tsv ${subdir2}_report.tsv; done

