#!/bin/bash

# This checks if the number of arguments is correct
# If the number of arguments is incorrect ( $# != 2) print error message and exit
if [[ $# != 2 ]]
then
  echo "backup.sh target_directory_name destination_directory_name"
  exit
fi

# This checks if argument 1 and argument 2 are valid directory paths
if [[ ! -d $1 ]] || [[ ! -d $2 ]]
then
  echo "Invalid directory path provided"
  exit
fi

targetDirectory=$1
destinationDirectory=$2

echo "First Command Line Argument (targetDirectory): $targetDirectory"
echo "Second Command Line Argument (destinationDirectory): $destinationDirectory"

currentTS=$(date +%s)

backupFileName="backup-${currentTS}.tar.gz"

# We're going to:
  # 1: Go into the target directory
  # 2: Create the backup file
  # 3: Move the backup file to the destination directory

# To make things easier, we will define some useful variables...

origAbsPath=$(pwd)

cd "$destinationDirectory" || exit 1 # <-
destAbsPath=$(pwd)

cd "$origAbsPath" || exit 1 # <-
cd "$targetDirectory" || exit 1 # <-

# Calculate the timestamp 24 hours ago
yesterdayTS=$((currentTS - 24 * 60 * 60))

declare -a toBackup

#for file in $(ls); do
    #echo "$file"
#done

#for file in $(ls); do
    #file_last_modified_date=$(date -r "$file" +%s)
    #if ((file_last_modified_date > yesterdayTS)); then
        #echo "$file was modified within the last 24 hours"
    #fi
#done

for file in $(ls); do
    file_last_modified_date=$(date -r "$file" +%s)
    if ((file_last_modified_date > yesterdayTS)); then
        echo "$file was modified within the last 24 hours"
        toBackup+=("$file") # Add the file to the toBackup array
    fi
done

# Compress and archive the files listed in the toBackup array
tar -czvf "$backupFileName" "${toBackup[@]}"

# Move the backup file to the destination directory
mv "$backupFileName" "$destAbsPath"

