# linux_scripts
Frequently used linux scripts

### merge_reads 

Merge my simulated reads into one file. Used for to create in silico simulated Illumina data for eML part training. It concatenates fastq.gz files based on sample names and strand information, appending each file to a new file in a specified output directory.


### merge_lanes_v2

Improved version of merging reads from different lanes. It groups files by sample name and strand (ignoring lane numbers) and concatenates all files within each group into a single output file. 