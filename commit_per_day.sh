#!/bin/bash

# Display usage/help message
show_help() {
  echo "Usage: $0"
  echo
  echo "This script calculates the average commits per day per user in a Git repository."
  echo "It also calculates the commit rate assuming only 2 workdays per week."
  echo
  echo "Requirements:"
  echo "  - Must be run inside a Git repository."
  echo
  echo "Output:"
  echo "  - Commits per day (normal rate)"
  echo "  - Commits per workday (assuming 2 workdays per week)"
  echo
  exit 1
}

# Check if inside a Git repository
check_git_repo() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: This script must be run inside a Git repository."
    show_help
  fi
}

# Get repository date range
get_repo_dates() {
  FIRST_COMMIT_DATE=$(git log --reverse --format="%ad" --date=iso | head -n 1 | awk '{print $1}')
  LAST_COMMIT_DATE=$(git log -1 --format="%ad" --date=iso | awk '{print $1}')

  if [ -z "$FIRST_COMMIT_DATE" ] || [ -z "$LAST_COMMIT_DATE" ]; then
    echo "Error: Unable to determine repository dates."
    show_help
  fi
}

# Calculate total active days
calculate_total_days() {
  TOTAL_DAYS=$(( ($(date -d "$LAST_COMMIT_DATE" +%s) - $(date -d "$FIRST_COMMIT_DATE" +%s)) / 86400 ))
  if [ "$TOTAL_DAYS" -eq 0 ]; then
    TOTAL_DAYS=1  # Prevent division by zero
  fi
}

# Calculate total workdays assuming 2 workdays per week
calculate_workdays() {
  TOTAL_WEEKS=$(( TOTAL_DAYS / 7 ))
  REMAINING_DAYS=$(( TOTAL_DAYS % 7 ))

  if [ "$REMAINING_DAYS" -gt 2 ]; then
    WORK_DAYS=$(( (TOTAL_WEEKS * 2) + 2 ))
  else
    WORK_DAYS=$(( (TOTAL_WEEKS * 2) + REMAINING_DAYS ))
  fi

  if [ "$WORK_DAYS" -eq 0 ]; then
    WORK_DAYS=1  # Prevent division by zero
  fi
}

# Calculate and display commit rates
calculate_commit_rates() {
  echo "Repository active from $FIRST_COMMIT_DATE to $LAST_COMMIT_DATE ($TOTAL_DAYS total days)"
  echo "Considering a 2-day workweek, estimated workdays: $WORK_DAYS"

  echo -e "\nAverage commits per day per user:"
  git shortlog -s -n --all | awk -v total_days="$TOTAL_DAYS" -v work_days="$WORK_DAYS" '
  {
      printf "%s %s : %.2f commits/day | %.2f commits/workday\n", $2, $3, $1/total_days, $1/work_days
  }'
}

# Main function
main() {
  check_git_repo
  get_repo_dates
  calculate_total_days
  calculate_workdays
  calculate_commit_rates
}

# Run the script
main
