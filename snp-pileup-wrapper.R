#!/usr/bin/env Rscript
suppressPackageStartupMessages({
    library(rlang)
    library(argparse)
})

args = commandArgs(TRUE)
if (length(args) == 0) {
    message('Run snp-pileup-wrapper.R --help for list of input arguments.')
    quit()
}

parser = ArgumentParser(description = 'Generate SNP read counts from matched tumor-normal BAM files.')

parser$add_argument('-v', '--verbose', action = "store_true", default = TRUE,
                    help = 'Print run info')
parser$add_argument('-sp', '--snp-pileup-path', required = TRUE,
                    help = 'Path to snp-pileup executable')
parser$add_argument('-vcf', '--vcf-file', required = TRUE,
                    help = 'Path to VCF file containing SNP positions')
parser$add_argument('-n', '--normal-bam', required = TRUE,
                    help = 'Path to normal sample BAM file')
parser$add_argument('-t', '--tumor-bam', required = TRUE,
                    help = 'Path to tumor sample BAM file')
parser$add_argument('-nn', '--normal-name', required = FALSE,
                    help = 'Name of normal sample')
parser$add_argument('-tn', '--tumor-name', required = FALSE,
                    help = 'Name of tumor sample')
parser$add_argument('-o', '--output-file', required = FALSE,
                    help = 'Name of output file [default tumor__normal.snp_pileup.gz]')
parser$add_argument('-p', '--pseudo-snps', required = FALSE, default = 50,
                    help = 'Do pileup at every p:th position [default %(default)s]')
parser$add_argument('-d', '--max-depth', required = FALSE, default = 4000,
                    help = 'Maximum read depth [default %(default)s]')

args = parser$parse_args()

# Prepare output --------------------------------------------------------------------------------------------------
snp_pileup_path = args$snp_pileup_path
normal_name     = args$normal_name      %||% gsub('.bam$', '', basename(args$normal_bam))
tumor_name      = args$tumor_name       %||% gsub('.bam$', '', basename(args$tumor_bam))
output_file     = args$output_file      %||% paste0(tumor_name, '__', normal_name, '.snp_pileup.gz')

if (file.exists(output_file)) {
    stop(paste(output_file, 'already exists. Remove before running.'), call. = F)
}

default_args = c('--count-orphans --gzip')

pileup_cmd = paste(
    snp_pileup_path,
    default_args,
    '-P', args$pseudo_snps,
    '-d', args$max_depth,
    args$vcf_file,
    output_file,
    args$normal_bam,
    args$tumor_bam
    )

system(pileup_cmd)