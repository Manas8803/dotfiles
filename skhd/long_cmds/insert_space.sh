#!/bin/bash

# Get the target space index from command line argument
target_space=$1

# Check if target space is valid
if ! [[ $target_space =~ ^[0-9]+$ ]]; then
  echo "Error: Invalid space number. Please enter a number between 1 and 9."
  exit 1
fi

target_space=$((target_space - 1))

# Create a new space (it will be created at the end)
yabai -m space --create

# Get total number of spaces after creation
total_spaces=$(yabai -m query --spaces | jq 'length')

# Move spaces by swapping in reverse order, starting from the end
# This shifts all spaces after the target space down by one position
for (( i = $total_spaces; i > $target_space + 1; i-- )); do
  # Small sleep to avoid race conditions
  sleep 0.001
  yabai -m space $((i-1)) --swap $i
done

# Focus the newly created space which is now next to our target space
yabai -m space --focus $((target_space + 1))