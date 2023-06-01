#!/bin/bash

# required software
# conda install -c bioconda sra-tools
# conda install -c bioconda fastqc
# conda install -c bioconda trimmomatic
# conda install -c bioconda hisat2
# conda install -c bioconda samtools
# conda install -c bioconda bedtools

# change to fastq format
fastq-dump --outdir 001_sra --gzip 001_sra/SRR7217928
fastq-dump --outdir 001_sra --gzip 001_sra/SRR7217929
fastq-dump --outdir 001_sra --gzip 001_sra/SRR7217930
echo "fastq-dump finished"

# check quality
fastqc 001_sra/SRR7217928.fastq.gz -o 001_sra/
fastqc 001_sra/SRR7217929.fastq.gz -o 001_sra/
fastqc 001_sra/SRR7217930.fastq.gz -o 001_sra/
echo "fastqc finished"

# trimming for quality
trimmomatic SE 001_sra/SRR7217928.fastq.gz 002_trim/SRR7217928_trim.fq.gz LEADING:30 TRAILING:30 -phred33
trimmomatic SE 001_sra/SRR7217929.fastq.gz 002_trim/SRR7217929_trim.fq.gz LEADING:30 TRAILING:30 -phred33
trimmomatic SE 001_sra/SRR7217930.fastq.gz 002_trim/SRR7217930_trim.fq.gz LEADING:30 TRAILING:30 -phred33
echo "trimmomatic finished"

# check quality
fastqc 002_trim/SRR7217928_trim.fq.gz -o 002_trim/
fastqc 002_trim/SRR7217929_trim.fq.gz -o 002_trim/
fastqc 002_trim/SRR7217930_trim.fq.gz -o 002_trim/
echo "fastqc finished"

# create index, this is done once
# hisat2-build -p 4 003_hisat2/GCA_000005845.2.fasta 003_hisat2/index/e.coli
# hisat2-build -p 4 003_hisat2/GCA_000007445.1.fasta 003_hisat2/index_gca_000007445/e.coli
# hisat2-build -p 4 003_hisat2/Escherichia_coli_str_k_12_substr_mg1655_gca_000005845.fa 003_hisat2/index_e_coli/e.coli
# echo "hisat2-build finished"

# align
hisat2 -x 003_hisat2/index_e_coli/e.coli -U 002_trim/SRR7217928_trim.fq.gz -S 003_hisat2/SRR7217928_align.sam
hisat2 -x 003_hisat2/index_e_coli/e.coli -U 002_trim/SRR7217929_trim.fq.gz -S 003_hisat2/SRR7217929_align.sam
hisat2 -x 003_hisat2/index_e_coli/e.coli -U 002_trim/SRR7217930_trim.fq.gz -S 003_hisat2/SRR7217930_align.sam
echo "hisat2 finished"

# sam to bam
samtools view -S -b 003_hisat2/SRR7217928_align.sam > 004_bam/SRR7217928_align.bam
samtools view -S -b 003_hisat2/SRR7217929_align.sam > 004_bam/SRR7217929_align.bam
samtools view -S -b 003_hisat2/SRR7217930_align.sam > 004_bam/SRR7217930_align.bam
echo "samtools finished"

# sorting
samtools sort 004_bam/SRR7217928_align.bam -o 004_bam/SRR7217928_align.sorted.bam
samtools sort 004_bam/SRR7217929_align.bam -o 004_bam/SRR7217929_align.sorted.bam
samtools sort 004_bam/SRR7217930_align.bam -o 004_bam/SRR7217930_align.sorted.bam
echo "samtools finished"

# gene
bedtools genomecov -ibam 004_bam/SRR7217928_align.sorted.bam -d > 004_bam/SRR7217928_gene.txt
bedtools genomecov -ibam 004_bam/SRR7217929_align.sorted.bam -d > 004_bam/SRR7217929_gene.txt
bedtools genomecov -ibam 004_bam/SRR7217930_align.sorted.bam -d > 004_bam/SRR7217930_gene.txt
echo "bedtools finished"

# statistics extraction with OperonSeqr code
# this needs the gff3 file in the 004_bam directory
python extract_coverage.py -c 004_bam/SRR7217928_gene.txt -g 004_bam/Escherichia_coli_str_k_12_substr_mg1655_gca_000005845.gff3 -o SRR7217928_stats.txt -p 004_bam/
python extract_coverage.py -c 004_bam/SRR7217929_gene.txt -g 004_bam/Escherichia_coli_str_k_12_substr_mg1655_gca_000005845.gff3 -o SRR7217929_stats.txt -p 004_bam/
python extract_coverage.py -c 004_bam/SRR7217930_gene.txt -g 004_bam/Escherichia_coli_str_k_12_substr_mg1655_gca_000005845.gff3 -o SRR7217930_stats.txt -p 004_bam/
echo "extract coverage finished"

# trim predictions from MicrobesOnline, this is done once
# python mo_ecoli_pred_trim.py
# echo "predictions from MicrobesOnline trimmed"

# adding predictions from Microbes Online
python add_pred.py -c 004_bam/SRR7217928_stats.txt -o 005_data/SRR7217928_data.csv
python add_pred.py -c 004_bam/SRR7217929_stats.txt -o 005_data/SRR7217929_data.csv
python add_pred.py -c 004_bam/SRR7217930_stats.txt -o 005_data/SRR7217930_data.csv
echo "extract coverage finished"