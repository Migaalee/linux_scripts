#!/bin/bash

# Migla 2024 for FASTQ subsampling to create smaller datasets.

# Setting default input file, output file, and subsample size
input_file="./input.fastq"
output_file="./output_subsampled.fastq"
subsample_size=10000

# Printing usage information for the script
echo "FASTQ Subsampling
USAGE:
$(basename $0) -i INPUT_FILE -o OUTPUT_FILE -s SUBSAMPLE_SIZE
Options:
  -i    Input FASTQ file (default: $input_file)
  -o    Output subsampled FASTQ file (default: $output_file)
  -s    Subsample size (default: $subsample_size)
"

# Processing command line options using getopts
while getopts i:o:s: option
do
        case "${option}"
                in
                        i) input_file=${OPTARG};;  # Option for input file
                        o) output_file=${OPTARG};;  # Option for output file
                        s) subsample_size=${OPTARG};;  # Option for subsample size
                        ?) echo " Wrong parameter $OPTARG";;  # Error message for unknown option
        esac
done

# Checking if input file exists
if [ ! -f "$input_file" ]; then
        echo "FATAL ERROR: Input file '$input_file' not found."
        exit 1
fi

# Setting up safe mode for script execution
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh compatibility
    set -euo pipefail
else
    # Bash 4.3 compatibility
    set -eo pipefail
fi
shopt -s nullglob globstar  # Enabling nullglob and globstar for better file pattern matching
IFS=$'\n\t'  # Setting internal field separator to newline and tab

# Performing random subsampling of FASTQ reads
seqtk sample -s 42 "$input_file" "$subsample_size" > "$output_file"

# Indicating that subsampling is completed
echo "Subsampling completed. Output subsampled FASTQ file: $output_file"

