# arise-sequencing-dada2

## background
Dada2 v.1.14 as part of the [make-otu-table](https://github.com/naturalis/galaxy-tool-make-otu-table) tool on the private [Galaxy server of Naturalis](https://galaxy.naturalis.nl) started to return memory allocation errors for larger (ie. Novaseq) datasets. Since future analyses of these datasets on Galaxy is still open for discussion, we wanted to test if Dada v.1.22 didn't have these issues. Current practice on our Galaxy platform is to merge R1 and R2 reads and subsequently trim primers and quality filter the merged reads. This contrasts the [Dada2 v.1.22 tutorial for paired-end data](https://benjjneb.github.io/dada2/bigdata_paired.html) in which quality filtering (and primer trimming) is done prior to merging of reads.

## data description
The [first dataset](https://drive.google.com/file/d/1S6YhKIrnqzmqu4RxRjE0PZJ4fxpf7F5J/view?usp=sharing) consists of the raw data (unmerged, containing primers), whereas the [second dataset](https://drive.google.com/file/d/1iZPC4_vsBDPZnOexT8y0cP44vtmE0CYI/view?usp=sharing) has the reads merged (Flash) and the primers removed (Cutadapt) in Galaxy.
