# arise-sequencing-dada2

## background
Dada2 v.1.14 as part of the [make-otu-table](https://github.com/naturalis/galaxy-tool-make-otu-table) tool on the private [Galaxy server of Naturalis](https://galaxy.naturalis.nl) started to return memory allocation errors for larger (ie. Novaseq) datasets. Since future analyses of these datasets on Galaxy is still open for discussion, we wanted to test if Dada v.1.22 didn't have these issues. Current practice on our Galaxy platform is to merge R1 and R2 reads and subsequently trim primers and quality filter the merged reads. This contrasts the [Dada2 v.1.22 tutorial for paired-end data](https://benjjneb.github.io/dada2/bigdata_paired.html) in which quality filtering (and primer trimming) is done prior to merging of reads.

## data description
The [first dataset](https://drive.google.com/file/d/1S6YhKIrnqzmqu4RxRjE0PZJ4fxpf7F5J/view?usp=sharing) consists of the raw data (unmerged, containing primers), whereas the [second dataset](https://drive.google.com/file/d/1iZPC4_vsBDPZnOexT8y0cP44vtmE0CYI/view?usp=sharing) has the reads merged (Flash) and the primers removed (Cutadapt) in Galaxy. The raw data consists of 576 gzipped fastq files (288 of each R1 and R2) representing demultiplexed Rbcl amplicons, still containing the primer sequences (forward = AGGTGAAGTTAAAGGTTCATACTTDAA, reverse = CCTTCTAATTTACCAACAACTG). For diatoms the expected length of the Rbcl fragment without primers is 263 nucleotides.

## setting up a conda environment
Analyses were done using a private [MaaS](https://maas.io/) (Metal as a Service) computing environment. After installing a Conda package manager, an environment with R, Cutadapt and Figaro can be created from the [yaml](https://github.com/naturalis/arise-sequencing-dada2/blob/main/arise-dada2.yml) file:\
`conda env create -n evn_name -f arise-dada2.yml`\
Where "env_name" is the name you like to use for this conda environment. Unfortunately not all R installed packages are saved to the yml file (Dada2 will be missing). After creating the new environment, activate it, start R and run the following command (check [Dada2 install instructions](https://benjjneb.github.io/dada2/dada-installation.html)):\
`if (!requireNamespace("BiocManager", quietly = TRUE))`\
`    install.packages("BiocManager")`\
`BiocManager::install("dada2", version = "3.14")`


## expectation
There are differences in raw and merged data with respect to error-learning (which is done separately in R1 and R2 for raw data in Dada2) and primer removal (both need to be present and anchored for data merged in Galaxy). We expect error-learning on both R1 and R2 (paired-end data) to be more accurate and likely result in less ASVs. Also we expect that most (if not all) of the higher abundance ASVs to be present in both datasets. 

## cutadapt on R1 and R2
In order to follow the [paired-end tutorial](https://benjjneb.github.io/dada2/bigdata_paired.html) of Dada2 for Big data, primer trimming was done in batch mode with Cutadapt using [auto_cutadapt.sh](https://github.com/naturalis/arise-sequencing-dada2/blob/main/auto_cutadapt.sh).\
`./auto_cutadapt.sh AGGTGAAGTTAAAGGTTCATACTTDAA CCTTCTAATTTACCAACAACTG`

## figaro
Use [Figaro](https://github.com/Zymo-Research/figaro#figaro) to determine Truncation length (truncLen) and Maximum number of expected errors (maxEE) parameters (to be used with the filterAndTrim function of Dada2). Be aware that although R1 and R2 reads may differ in length, all reads within R1 or R2 need to be of the same length. The presence of shorter reads will also cause Figaro to fail; use Cutadapt with minimum and maximum length parameters. In this case we used Cutadapt with -l280 -m280 (=< 263 + shortest oligo). Also Figaro requires the input files to strictly adhire to Illumina naming standard (some_identifier_L001_R1.fastq.gz doesn't work; some_identifier_S1_L001_R1.fastq.gz does work). After analysing the [results](https://github.com/naturalis/arise-sequencing-dada2/tree/main/figaro_output) of sample E035 it was decided not to run Figaro for all samples, but use truncLen 263 and don't set maxEE and truncQ (which keeps them at their default values of 'inf' and '2' respectively).

## dada2
Dada2 requires reads without primer sequences. Fastq filenames are split on underscores and the resulting basename (the part before the first underscore) needs to be unique. In case of the example datasets the blancs (eBlanc_...) needed to be renamed. For the first dataset (unmerged) we followed the ['big data: paired-end' tutorial](https://benjjneb.github.io/dada2/bigdata_paired.html), for the second (merged) dataset we followed the 
['big data' tutorial](https://benjjneb.github.io/dada2/bigdata.html). Parameters for filterAndTrim were identical in both cases.

### filter on sequence length
`seqlens <- nchar(getSequences(seqtab.nochim))`\
`seqtab.nochim.l263 <- seqtab.nochim[,seqlens == 263]`

### filter on ASV abundance
`abundances <- colSums(seqtab.nochim.l263)`\
`seqtab.nochim.l263.abgt100 <- seqtab.nochim.l263[,abundances >= 100]`

### export ASVs as fasta
The uniquesToFasta(...) function of Dada2.\
`uniquesToFasta(getUniques(seqtab), fout="uniqueSeqs.fasta", ids=paste0("Seq", seq(length(getUniques(seqtab)))))`

## results
|Dataset|Initial|Merging_(env)|Marker|ASVs|ASVs_nochimera|ASVs_nochim length_263|ASVs_nochim l263 abundance>100|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|1.|unmerged|Dada2_(MaaS)|RbcL|9595|2251|2137|1207|
|2.|merged|Flash_(Galaxy)|RbcL|14830|2833|2833|1220|

Analysis of dataset 1 resulted in 2251 ASVs, of which 114 were longer than 263 nt (truncLen 263 both R1 and R2 can still result in merged reads exceeding 263).\
Analysis of dataset 2 resulted in 2833 ASVs all of length 263 (using filterAndTrim with truncLen 263). \
After filtering on abundance 100 or more, the number of ASVs was roughly similar.

## data overlap
2089 ASVs of dataset 1 were also present in the 2833 ASVs of the dataset 2.\
162 ASVs of the dataset 1 were missing from the 2833 ASVs of the dataset 2; of these 114 were larger than 263 nt and virually all represented bacterial sequences.\
[**check_presence.py**](https://github.com/naturalis/arise-sequencing-dada2/blob/main/check_presence.py) (compared lists only contain sequences, no headers)
|Dataset|Initial|ASVs nochim l263 ab>100|in merged|in merged|in unmerged|in unmerged|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|1.|unmerged|1207|1163 present|44 missing|||
|2.|merged|1220|||1163 present|57 missing|





