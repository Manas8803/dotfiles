#!/bin/bash

# Load global styles, colors and icons
source "$CONFIG_DIR/globalstyles.sh"

# Defaults
spaces=(
  background.height=24
  background.corner_radius=50
  icon.padding_left=2
  icon.padding_right=2
  label.padding_right=4
)

# Get all spaces
SPACES=($(yabai -m query --spaces index | jq -r '.[].index'))

for SID in "${SPACES[@]}"; do
  sketchybar --add space space.$SID left   \
    --set space.$SID "${spaces[@]}"        \
    script="$PLUGIN_DIR/app_space.sh $SID" \
    associated_space=$SID                  \
    icon=$SID                              \
    --subscribe space.$SID mouse.clicked front_app_switched space_change update_yabai_icon space_windows_change
done
