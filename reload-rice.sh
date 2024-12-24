#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Reload Rice
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author manas8803
# @raycast.authorURL https://raycast.com/manas8803

yabai --restart-service
sleep 1
sketchybar --reload