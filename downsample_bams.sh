#!/bin/bash

# Target average depth
target_depth=$1  # Provide the target depth as the first argument to the script

# Output directory for downsampled BAM files
output_dir="downsampled_bams"
mkdir -p "$output_dir"

# File to store average depths
avg_depth_file="average_depths.txt"
echo -e "Sample\tAverage_Depth" > "$avg_depth_file"

# Loop through each BAM file in the current directory
for bam_file in *.bam; do
    sample_name=$(basename "$bam_file" .bam)  # Extract sample name

    echo "Processing $sample_name..."

    # Calculate depth and compute average depth
    avg_depth=$(samtools depth -a "$bam_file" | awk '{sum+=$3} END {print sum/NR}')
    echo -e "${sample_name}\t${avg_depth}" >> "$avg_depth_file"

    # Validate avg_depth
    if [[ "$avg_depth" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        # Calculate the downsampling fraction
        if (( $(echo "$avg_depth > $target_depth" | bc -l) )); then
            fraction=$(echo "scale=4; $target_depth / $avg_depth" | bc)
            echo "Downsampling $sample_name to target depth $target_depth (fraction: $fraction)"

            # Downsample BAM file with seed 42
            samtools view -s "${fraction}.42" -b "$bam_file" > "$output_dir/${sample_name}_downsampled.bam"
            echo "$sample_name downsampled."
        else
            echo "$sample_name already below target depth. Copying as is."
            cp "$bam_file" "$output_dir/${sample_name}_downsampled.bam"
        fi
    else
        echo "Error: Non-numeric depth value for $sample_name. Skipping..."
        continue
    fi
done

echo "All samples processed. Downsampled BAM files saved in $output_dir."

