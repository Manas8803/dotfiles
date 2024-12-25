#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 /path/to/wallpaper"
    exit 1
fi

WALLPAPER="$1"
TEMP_JPG="/tmp/wallpaper_$$.jpg"

if [ ! -f "$WALLPAPER" ]; then
    echo "Error: File $WALLPAPER does not exist"
    exit 1
fi

# Convert to JPG first (if not already JPG)
if [[ "$WALLPAPER" != *.jpg ]] && [[ "$WALLPAPER" != *.JPG ]]; then
    sips -s format jpeg "$WALLPAPER" --out "$TEMP_JPG" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        WALLPAPER="$TEMP_JPG"
        echo "Converted image to JPG format"
    fi
fi

# More detailed AppleScript
osascript <<EOD
tell application "System Events"
    set desktopCount to count of desktops
    repeat with i from 1 to desktopCount
        tell desktop i
            set picture rotation to 0
            set random order to false
            set picture to "$WALLPAPER"
        end tell
    end repeat
end tell

tell application "Finder"
    set desktop picture to POSIX file "$WALLPAPER"
end tell
EOD

# Update database directly
sqlite3 "${HOME}/Library/Application Support/Dock/desktoppicture.db" "update data set value = '$WALLPAPER';" 2>/dev/null

# Restart Dock and System Events
killall Dock
killall "System Events"

# Cleanup
if [ -f "$TEMP_JPG" ]; then
    rm "$TEMP_JPG"
fi

echo "Wallpaper change completed. If not visible immediately:"
echo "1. Try logging out and back in"
echo "2. Check System Settings > Privacy & Security > Files and Folders permissions"
