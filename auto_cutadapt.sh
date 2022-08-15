#!/bin/bash

if [ "$1" == "-h" ]; then
  printf "\nUsage: `basename $0` \$1 \$2
\$1\tfwd-seq
\$2\trev-seq
\nThis script assumes unmerged HiSeq or NovaSeq data in the format
*_R1_001.fastq.gz and *_R2_001.fastq.gz (the data is demultiplexed) and 
removes forward and reverse primers provided as \$1 and \$2. The primers
will be at the start of the sequence and none should be in reverse
complement. Cutadapt will be executed using the '-g' option.

Cutadapt is set to run with the following parameters:
error rate \t 0.2
overlap \t 5
min length \t 10\n\n"
  exit 0
fi

# check if output directory already exists, if not create one
[ -d out_cutadapt ] && { printf "out EXISTS !!! \nplease remove to continue\n"; exit 1; }
mkdir -p out_cutadapt

# run cutadapt (using -g and primer $1) on R1
printf "\n\nProcessing R1 reads\n"
count=0
for i in *_R1_001\.fastq\.gz
do
    cutadapt -g "$1" -e 0.2 -m 10 -O 5 -o out_cutadapt/"$i" "$i" --quiet
    count=$[count + 1]
    printf "$count processed: $i\n"
done

# run cutadapt (using -g and primer $2) on R2
printf "\n\nProcessing R2 reads\n"
count=0
for i in *_R2_001\.fastq\.gz
do
    cutadapt -g "$2" -e 0.2 -m 10 -O 5 -o out_cutadapt/"$i" "$i" --quiet
    count=$[count + 1]
    printf "$count processed: $i\n"
done

# modify the output names to indicate they passed cutadapt
for i in out_cutadapt/*.gz
do
    mv "$i" "$(echo "$i" | sed 's/\.fastq\.gz$/\.cutadapt\.fastq\.gz/g')"
done
