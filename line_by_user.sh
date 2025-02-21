#!/bin/bash

# Check if the username is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <username> <directory>"
  exit 1
fi

# Check if the directory is provided as the second argument
if [ -z "$2" ]; then
  echo "Usage: $0 <username> <directory>"
  exit 1
fi

# Assign the arguments to variables
USERNAME="$1"
DIRECTORY="$2"

# Run the git command to count lines added by the user in the directory
git log --author="$USERNAME" --numstat --pretty=format: -- "$DIRECTORY" | 
awk '{added+=$1} END {print "User:", "'"$USERNAME"'", "Lines added:", added}'
