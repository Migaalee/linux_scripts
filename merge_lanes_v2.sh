#!/bin/bash
# Migla 2023 updated script for merging FASTQ files from different Illumina lanes.

# Setting default input directory, output directory, and file extension
input_dir="./"
ext='fq.gz'

# Printing usage information for the script
echo " Merge Illumina lanes
 USAGE:
 $(basename $0) -o OUTPUT_DIR [-i INPUT_DIR] [-e EXTENSION]
 Options:
   -i    Input directory (default: $input_dir)
   -o    Output directory (will be created)
   -e    Extension without first dot (default: $ext)
"

# Processing command line options using getopts
while getopts o:i:e: option
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

# Checking if output directory is specified
if [ -z ${output_dir+x} ];
then
        echo " FATAL ERROR: Please specify output directory:  -o OUTPUT_DIR"
        exit 9
fi

# Checking if output directory already exists
if [ -d "${output_dir}" ]; then
        echo " FATAL ERROR: Directory '$output_dir' was found. Please specify a new name"
        exit 7
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

# Creating the output directory
mkdir "$output_dir"

# Declaring an associative array to group files
declare -A file_groups

# Looping through files in the input directory with the specified extension
for sample_file in ${input_dir}/*_*.${ext};
do
  # Extracting the base name of the file
  base_name=$(basename "$sample_file")
  # Extracting the sample name from the base name
  sample_name=$(echo "$base_name" | cut -f 1 -d "_")
  # Extracting the strand information from the base name
  sample_strand=$(echo "$base_name" | rev | cut -d "_" -f 2 | rev)
  # Creating a unique key for each group based on sample name and strand
  group_key="${sample_name}_${sample_strand}"

  # Appending the current file to its respective group in the associative array
  file_groups[$group_key]+="$sample_file "
done

# Looping through each group in the associative array
for group in "${!file_groups[@]}";
do
  echo "Merging files for group: $group"
  # Concatenating all files in the current group
  cat ${file_groups[$group]} > "${output_dir}/${group}_merged.${ext}"
done

# Indicating that merging is completed
echo "Merging completed."
