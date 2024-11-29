#!/bin/bash

# File to store average depths
avg_depth_file="average_depths.txt"
echo -e "Sample\tAverage_Depth" > "$avg_depth_file"

# Loop through each BAM file in the current directory
for bam_file in *.bam; do
    sample_name=$(basename "$bam_file" .bam)  # Extract sample name

    echo "Processing $sample_name..."

    # Calculate depth and compute average depth on the fly
    avg_depth=$(samtools depth -a "$bam_file" | awk '{sum+=$3} END {print sum/NR}')

    # Save the result
    echo -e "${sample_name}\t${avg_depth}" >> "$avg_depth_file"
done

echo "All samples processed. Average depths saved to $avg_depth_file."
