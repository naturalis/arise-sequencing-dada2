# arise-sequencing-dada2

## background
Dada2 v.1.14 as part of the [make-otu-table](https://github.com/naturalis/galaxy-tool-make-otu-table) tool on the private [Galaxy server of Naturalis](https://galaxy.naturalis.nl) started to return memory allocation errors for larger (ie. Novaseq) datasets. Since future analyses of these datasets on Galaxy is still open for discussion, we wanted to test if Dada v.1.22 didn't have these issues. Current practice on our Galaxy platform is to merge R1 and R2 reads and subsequently trim primers and quality filter the merged reads. This contrasts the [Dada2 v.1.22 tutorial for paired-end data](https://benjjneb.github.io/dada2/bigdata_paired.html) in which quality filtering (and primer trimming) is done prior to merging of reads.

## data description
The [first dataset](https://drive.google.com/file/d/1S6YhKIrnqzmqu4RxRjE0PZJ4fxpf7F5J/view?usp=sharing) consists of the raw data (unmerged, containing primers), whereas the [second dataset](https://drive.google.com/file/d/1iZPC4_vsBDPZnOexT8y0cP44vtmE0CYI/view?usp=sharing) has the reads merged (Flash) and the primers removed (Cutadapt) in Galaxy. The raw data consists of 576 gzipped fastq files (288 R1 and R2) representing demultiplexed Rbcl amplicons, still containing the primer sequences (forward = AGGTGAAGTTAAAGGTTCATACTTDAA, reverse = CCTTCTAATTTACCAACAACTG). For diatoms the expected length of the Rbcl amplicon is 263 nucleotides.

## setting up a conda environment
Analyses were done using a private [MaaS](https://maas.io/) (Metal as a Service) computing environment. After installing a Conda package manager, an environment with Dada2, Cutadapt and Figaro ucan be created from the [yaml](https://github.com/naturalis/arise-sequencing-dada2/blob/main/arise-dada2.yml) file:\
`conda env create -n DADA2 -f arise-dada2.yml`

## expectation
There are differences in raw and merged data in respect to error-learning (which is done separately in R1 and R2 for raw data in Dada2) and primer removal (both need to be present and anchored in merged data in Galaxy). We expect error-learning on both R1 and R2 to be more accurate and likely result in less ASVs. Also we expect that most (if not all) of the higher abundance ASVs to be present in both datasets. 

## cutadapt on R1 and R2
In order to follow "a Dada2 worklflow for Big data: [paired-end" tutorial](https://benjjneb.github.io/dada2/bigdata_paired.html), primer trimming was done in batch mode with Cutadapt using [auto_cutadapt.sh](https://github.com/naturalis/arise-sequencing-dada2/blob/main/auto_cutadapt.sh).

## figaro
Use [Figaro](https://github.com/Zymo-Research/figaro#figaro) to determine Truncation length (truncLen) and Maximum number of expected errors (maxEE) parameters (to be used by filterAndTrim of Dada2). Be aware that although R1 and R2 reads may differ in length, all reads within R1 or R2 need to be of the same length. The presence of shorter reads will also cause Figaro to fail, use Cutadapt with minimum and maximum length parameters. In this case we used Cutadapt with -l280 -m280 (=< 263 + shortest oligo). Also Figaro requires the input files to strictly adhire to Illumina naming standard (some_identifier_L001_R1.fastq.gz doesn't work; some_identifier_S1_L001_R1.fastq.gz does work). After analysing the [results](https://github.com/naturalis/arise-sequencing-dada2/tree/main/figaro_output) of sample E035 it was decided not to run Figaro for all samples, but use truncLen 263 and don't specify truncLen and don't set maxEE and truncQ (which keeps them at their default values of 'inf' and '2' respectively).

## dada2
Dada2 requires reads without primer sequences and no duplicates are allowed before the first underscore in the name of the fastq files.

## results
Analysis of the raw data resulted in 2251 ASVs, of which 114 were longer than 263 nt.\
Analysis of the merged data resulted in 2833 ASVs all of length 263.

## data overlap
2089 ASVs of the raw dataset were also present in the 2833 ASVs of the merged dataset.\
162 ASVs of the raw dataset were missing from the 2833 ASVs of the merged dataset; of these 114 were larger than 263 nt and virually all represented bacterial sequences.\
[**check_presence.py**](https://github.com/naturalis/arise-sequencing-dada2/blob/main/check_presence.py) (compared lists only contain sequences, no headers)




