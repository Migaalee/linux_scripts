#!/bin/bash

# Migla 2024 for converting FASTA files to FASTQ format with placeholder quality scores.

# Setting default input file, output file, and placeholder quality score
input_file="./input.fasta"
output_file="./output.fastq"
placeholder_quality='I'

# Printing usage information for the script
echo "FASTA to FASTQ Conversion
USAGE:
$(basename $0) -i INPUT_FILE -o OUTPUT_FILE [-q QUALITY_SCORE]
Options:
  -i    Input FASTA file (default: $input_file)
  -o    Output FASTQ file (default: $output_file)
  -q    Placeholder quality score (default: $placeholder_quality)
"

# Processing command line options using getopts
while getopts i:o:q: option
do
        case "${option}"
                in
                        i) input_file=${OPTARG};;  # Option for input file
                        o) output_file=${OPTARG};;  # Option for output file
                        q) placeholder_quality=${OPTARG};;  # Option for quality score
                        ?) echo " Wrong parameter $OPTARG";;  # Error message for unknown option
        esac
done

# Checking if input file exists
if [ ! -f "$input_file" ]; then
        echo "FATAL ERROR: Input file '$input_file' not found."
        exit 1
fi

# Creating the output FASTQ file
touch "$output_file"

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

# Reading sequences from input FASTA file and writing to output FASTQ file with placeholder quality
while IFS= read -r line; do
  if [[ $line == ">"* ]]; then
    # Header line, replace leading '>' with '@'
    echo "@${line:1}" >> "$output_file"
  else
    # Sequence line, add placeholder quality scores
    echo "$line" >> "$output_file"
    echo "+ " >> "$output_file"
    seq_length=${#line}
    for ((i = 0; i < seq_length; i++)); do
      echo -n "$placeholder_quality" >> "$output_file"
    done
    echo >> "$output_file"
  fi
done < "$input_file"

# Indicating that conversion is completed
echo "Conversion completed. Output FASTQ file: $output_file"

