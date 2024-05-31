#!/bin/bash
### set the appropriate servers that you want to copy to
servers=("Neon2-mgmt1" "Neon2-mgmt2" "Neon2-mgmt3" "Neon2-mgmt4" "Neon2-compute1" "Neon2-compute2" "Neon2-compute3" "Neon2-compute4" "Neon2-compute5" "Neon2-compute6")
### set the appropriate file that you want to copy
file="##FILE.##FORMAT"
### set the destination folder that your file will copy to
dest="/tmp"

### loop to run scp to each server
for server in "${servers[@]}"; do
        scp "$file" "$server:$dest"
done
### kill the script
killall clustercopy.sh
