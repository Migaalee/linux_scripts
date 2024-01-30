#!/bin/bash
# Migla 2024 for merging FASTQ files from different Illumina lanes into a single output folder. For forward and reverse reads.

# Setting default input directory, output directory, and file extension
input_dir="./"
output_dir="./merged_data"
ext='fq.gz'

# Printing usage information for the script
echo "Merge Illumina lanes
USAGE:
$(basename $0) [-i INPUT_DIR] [-o OUTPUT_DIR] [-e EXTENSION]
Options:
  -i    Input directory (default: $input_dir)
  -o    Output directory (default: $output_dir)
  -e    Extension without first dot (default: $ext)
"

# Processing command line options using getopts
while getopts i:o:e: option
do
        case "${option}"
                in
                        i) input_dir=${OPTARG};;  # Option for input directory
                        o) output_dir=${OPTARG};;  # Option for output directory
                        e) ext=${OPTARG};;  # Option for file extension
                        ?) echo " Wrong parameter $OPTARG";;  # Error message for unknown option
        esac
done
shift "$(($OPTIND -1))"  # Shifting argument pointer so only non-option arguments are left

# Checking if input directory exists
if [ ! -d "$input_dir" ]; then
        echo "FATAL ERROR: Input directory '$input_dir' not found."
        exit 1
fi

# Creating the output directory if it doesn't exist
mkdir -p "$output_dir"

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

# Looping through files in the input directory with the specified extension
for forward_file in "${input_dir}"/*_1.${ext}; do
  # Check if the corresponding reverse file exists
  reverse_file="${forward_file/_1./_2.}"
  if [ -f "$reverse_file" ]; then
    # Copy the forward and reverse reads to the output directory
    cp "$forward_file" "$output_dir/"
    cp "$reverse_file" "$output_dir/"
  fi
done

# Indicating that merging is completed
echo "Merging completed. Merged files are in: $output_dir"
