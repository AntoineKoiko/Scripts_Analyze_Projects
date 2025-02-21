#!/bin/bash

# Check if the date is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <YYYY-MM-DD>"
  echo "Finds the last commit before the given date and checks it out."
  exit 1
fi

# Assign the date argument, appending 00:00:00 if time is not provided
DATE="$1 00:00:00"

# Find the last commit before the given date
COMMIT_HASH=$(git rev-list -n 1 --before="$DATE" HEAD)

# Check if a commit was found
if [ -z "$COMMIT_HASH" ]; then
  echo "No commit found before $DATE."
  exit 1
fi

# Checkout the commit
echo "Checking out commit $COMMIT_HASH from before $DATE..."
git checkout "$COMMIT_HASH"
