# MicroPro

MicroPro is a general framework for profiling of both known and unknown microbial organisms for metagenomics dataset. A microbe is considered known/unknown if its whole genome is known/unknown according to the [NCBI Reference Sequence Database](https://www.ncbi.nlm.nih.gov/refseq/). MicroPro has two pipelines: [MicrobialPip](https://github.com/zifanzhu/MicroPro/MicrobialPip) and [ViralPip](https://github.com/zifanzhu/MicroPro/ViralPip). MicrobialPip considers all the microbial organisms including bacteria, archaea and viruses while ViralPip only extracts known and unknown viruses from the provided metagenomics dataset.

## Description

MicroPro consists of the following four modules:    

1. Map reads to NCBI Refseq database and perform known microbial species profiling
2. Cross-assemble unmapped reads
3. Detect virus from assembled contigs (ViralPip only)
4. Perform contig binning and unknown organisms profiling

MicrobialPip and ViralPip are mostly similar except that ViralPip has additional procedures (Module 3) for virus detection. In terms of output, MicrobialPip will provide an abundance table for all the microbes while ViralPip only ouputs the abundance table of the viruses.

## Dependencies

Depedencies of MicroPro are listed below. You can click the software name to navigate to its website. Note that after installing each dependency, you should [add it to path](https://unix.stackexchange.com/questions/26047/how-to-correctly-add-a-path-to-path) to ensure MicroPro's normal run.

- Python 3 (>= 3.5) version of [Miniconda](https://conda.io/miniconda.html) and [Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) (>= 5.3.0)
  - MicroPro is realized via Snakemake [1], a text-based workflow system. Thus, Snakemake is a must for running any pipeline of MicroPro. With a Python 3 version of Miniconda install, you can install Snakemake using the following command: (See [Snakemake manual](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) for more.)

    ```
    $ conda install -c bioconda -c conda-forge snakemake
    ```

- [Centrifuge](https://ccb.jhu.edu/software/centrifuge/) (>= 1.0.3)
  - Centrifuge [2] is used for sequence alignment in Module 1. After installing Centrifuge, you need to download and index the reference genomes for bacteria, archaea and viruses from NCBI Refseq Database with the following commands: (See [Centrifuge manual](https://ccb.jhu.edu/software/centrifuge/manual.shtml#database-download-and-index-building) for more.)

    ```
    $ cd <PATH_TO_CENTRIFUGE>
    $ centrifuge-download -o taxonomy taxonomy
    $ centrifuge-download -o library -m -d "archaea,bacteria,viral" refseq > seqid2taxid.map
    $ cat library/*/*.fna > input-sequences.fna
    $ centrifuge-build -p 4 --conversion-table seqid2taxid.map --taxonomy-tree taxonomy/nodes.dmp --name-table taxonomy/names.dmp input-sequences.fna abv
    $ mkdir database
    $ mv abv* database
    $ rm -r taxonomy library
    ```

    `<PATH_TO_CENTRIFUGE>` is the directory where you install Centrifuge. The indexed genomes are located in `<PATH_TO_CENTRIFUGE>/database` with prefix `abv`. It's recommended not to change the directory name as well as the prefix, since otherwise MicroPro would not locate the reference genomes.

- [Megahit](https://github.com/voutcn/megahit) (>= 1.1.3)
  - Megahit [3] is used for the assembly of unmapped reads in Module 2.

- [R](https://www.r-project.org/) (>= 3.3.1) and three R packages: [VirFinder](https://github.com/jessieren/VirFinder), [ShortRead](https://bioconductor.org/packages/release/bioc/html/ShortRead.html) and [data.table](https://cran.r-project.org/web/packages/data.table/index.html)
  - 'VirFinder' [4] utilizes a logistic regression model to differ viral sequences from bacterial sequences.
  - 'ShortRead' is a useful R package for input and output of files with various extensions like 'fasta', 'fastq', etc. These file formats are ubiquitous in metagenomics analysis.
  - 'data.table' allows fast data.frame operations.
  - 'VirFinder', 'ShortRead' and 'data.table' are required in Module 3 (ViralPip only) and Module 4 respectively.

- [BWA](http://bio-bwa.sourceforge.net/) (>= 0.7.15) and [SAMtools](http://samtools.sourceforge.net/) (>= 1.4.1)
  - BWA [5] and SAMtools [6] are used for the generation of unknown organisms abundance table in Module 4.

- [MetaBAT 2](https://bitbucket.org/berkeleylab/metabat) (>= 2.12.1)
  - MetaBAT 2 [6] is used for contig binning in Module 4.

## Running MicroPro

MicroPro accepts both single-read and paired-end sequenced reads with FASTQ format as inputs. To improve profiling accuracy, it's recommended to perform raw reads preprocessing including **adaptor removal** and **host genome removal**.

### Getting started

To install MicrobialPip, clone the github repository and enter MicrobialPip directory with

```
$ git clone https://github.com/zifanzhu/MicroPro.git
$ cd MicroPro/MicrobialPip
```

(To install ViralPip, replace the second command with `$ cd MicroPro/ViralPip`.)

URC, URC-S and FCV are three useful tools required in MicroPro. Their compiled binaries are in folder `utils/`. To make them executable, run

```
$ chmod 755 utils/*
```

### Parameters generation

In this step, you tell MicroPro the location of your data and other parameters it needs. For single-read data, use

```
$ R --no-save --file=scripts/parameters.R --args S <PATH_TO_DATA> <FASTQ> <PATH_TO_CENTRIFUGE> <MIN_CONTIG_LENGTH>
```

For paired-end data, use


```
$ R --no-save --file=scripts/parameters.R --args P <PATH_TO_DATA> <R1> <R2> <FASTQ> <PATH_TO_CENTRIFUGE> <MIN_CONTIG_LENGTH>
```

`S` or `P` indicates single-read or paired-end data. `<PATH_TO_DATA>` is the directory of your data. `<PATH_TO_CENTRIFUGE>` is the directory where you install Centrifuge. It tells MicroPro where to locate the reference genomes. It's recommended to remove the final slash in `<PATH_TO_DATA>` and `<PATH_TO_CENTRIFUGE>`. For example, if your data path is '/home/data/'. It's better to replace `<PATH_TO_DATA>` with `/home/data` instead of `/home/data/`. `<MIN_CONTIG_LENGTH>` refers to the minimum length of the contigs to report in the cross-assembly step. We suggest setting it as 1000. But you may choose whatever fits your study.

`<FASTQ>` or `<R1> <R2> <FASTQ>` instructs MicroPro how to generate sample names. `<FASTQ>` refers to the file extension, like `.fastq`, `.fq`, etc. `<R1>` and `<R2>` refer to the way that two pairs are represented in the file name, like `_1`, `_2` or `_R1`,`_R2`. For single-read data, MicroPro will remove `<FASTQ>` in the file name and use the rest as the sample name. For paired-end data, MicroPro will separate the file name by `<R1>` if the file is pair 1 (or `<R2>` accordingly) and use the part before `<R1>` (or `<R2>`) as the sample name. Note that this assumes the parts before `<R1>` and `<R2>` are the same for pair 1 and pair 2 file of same sample. If it's not the case, you should rename your data in this way.

For example, for a single-read dataset of 3 samples with file names: `A.fastq B.fastq C.fastq`, MicroPro will use `A B C` as three samples' sample names, if you use the following command:

```
$ R --no-save --file=scripts/parameters.R --args S <PATH_TO_DATA> .fastq <PATH_TO_CENTRIFUGE>
```

For a paired-end dataset of 3 samples with file names: `A_1.fq A_2.fq B_1.fq B_2.fq C_1.fq C_2.fq`, MicroPro will also use `A B C` as three samples' sample names, if you use the following command:

```
$ R --no-save --file=scripts/parameters.R --args P <PATH_TO_DATA> _1 _2 .fq <PATH_TO_CENTRIFUGE>
```

Note that the catenation of strings `<sample_name_generated_by_MicroPro>`, `<R1>` (or `<R2>`) and `<FASTQ>` must be the same as the corresponding file name, like in previous example, catenating `A`, `_1` and `.fq` will give you `A_1.fq`. This means if you have a paired-end dataset of 3 samples with file names: `A_1_001.fq A_2_001.fq B_1_001.fq B_2_001.fq C_1_001.fq C_2_001.fq`, the following command will result in an error when running MicroPro, since for example the catenation of `A`, `_1` and `.fq` is not a file name.

```
$ R --no-save --file=scripts/parameters.R --args P <PATH_TO_DATA> _1 _2 .fq <PATH_TO_CENTRIFUGE>
```

The correct command should be:

```
$ R --no-save --file=scripts/parameters.R --args P <PATH_TO_DATA> _1_001 _2_001 .fq <PATH_TO_CENTRIFUGE>
```

### Running MicrobialPip or ViralPip

Running MicrobialPip and ViralPip are exactly the same. You just need to make sure that you're in the folder corresponding to the pipeline you want. For single-read data, run

```
$ snakemake -j <#_cores> -p -s Snakefile-S
```

For paired-end data, run

```
$ snakemake -j <#_cores> -p -s Snakefile-P
```

`-j <#_cores>` will tell Snakemake to use at most `<#_cores>` cores. Snakemake supports parallel processing when providing more than one core. This saves lots of time especially when you have a large amount of samples. See [Snakemake manual](https://snakemake.readthedocs.io/en/stable/executable.html) for more Snakemake executing options.

### Outputs

The known and unknown abundance tables are stored in folder `res/`. Each of them has a 'csv' version as well as a 'rds' version, which can be opened and edited by R. Every table contains a sample-by-organism matrix with each entry representing a known/unknown organism's relative abundance in a sample. For MicrobialPip, 'centrifuge_species_abundance' is the known abundance table while 'unknown_abundance' is the unknown table. For ViralPip, 'centrifuge_viral_species_abundance' is for the known while 'unknown_viral_abundance' is for the unknown. Note that a microbe is output in the abundance table only if it appears in at least one sample. **Thus, for viral abundance, it's possible that all the viruses of some sample have abundance zero since virus usually makes up a very small proportion of the whole microbial community.** Also, combined abundance table (a combination of known and unknown abundances) is also output for both versions. It's named 'combined_abundance' for MicrobialPip and 'combined_viral_abundance' for ViralPip.

The intermediate results are stored in corresponding folders. In particular, centrifuge results are stored in `1_centrifuge/`; cross-assembly results are in `3_cross_assembly/megahit_out/`; VirFinder results (ViralPip only) are in `4_virfinder/4_4_vf_summary/vf_results.rds`; Contig binning results are in `5_binning/bins_dir/` for MicrobialPip or `viral_3_binning/bins_dir/` for ViralPip.

The intermediate log and benchmark files are stored in `logs/` and `benchmarks/`. The benchmark file records the wall time and the memory usage of a particular intermediate process.

## Copyright and License Information

Copyright (C) 2018 University of Southern California

Authors: Zifan Zhu, Jie Ren, Fengzhu Sun

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

Commercial users should contact Prof. Fengzhu Sun (<fsun@usc.edu>), copyright at University of Southern California.

## References

[1] Köster, Johannes, and Sven Rahmann. "Snakemake—a scalable bioinformatics workflow engine." Bioinformatics 28.19 (2012): 2520-2522.

[2] Kim, Daehwan, et al. "Centrifuge: rapid and sensitive classification of metagenomic sequences." Genome research (2016).

[3] Li, Dinghua, et al. "MEGAHIT v1. 0: A fast and scalable metagenome assembler driven by advanced methodologies and community practices." Methods 102 (2016): 3-11.

[4] Ren, Jie, et al. "VirFinder: a novel k-mer based tool for identifying viral sequences from assembled metagenomic data." Microbiome 5.1 (2017): 69.

[5] Li, Heng. "Aligning sequence reads, clone sequences and assembly contigs with BWA-MEM." arXiv preprint arXiv:1303.3997 (2013).

[6] Li, Heng, et al. "The sequence alignment/map format and SAMtools." Bioinformatics 25.16 (2009): 2078-2079.

[7] Kang, Dongwan D., et al. "MetaBAT, an efficient tool for accurately reconstructing single genomes from complex microbial communities." PeerJ 3 (2015): e1165.
