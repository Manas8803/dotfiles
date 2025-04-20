#!/bin/bash

# Get the current space index
current_space=$(yabai -m query --spaces --space | jq '.index')

# Create a new space (it will be created at the end)
yabai -m space --create

# Get total number of spaces after creation
total_spaces=$(yabai -m query --spaces | jq 'length')

# Move spaces by swapping in reverse order, starting from the end
# This shifts all spaces after the current space down by one position
for (( i = $total_spaces; i > $current_space + 1; i-- )); do
  # Small sleep to avoid race conditions
  sleep 0.001
  yabai -m space $((i-1)) --swap $i
done

# Focus the newly created space which is now next to our current space
yabai -m space --focus $((current_space + 1))

echo "Created new space next to space $current_space"