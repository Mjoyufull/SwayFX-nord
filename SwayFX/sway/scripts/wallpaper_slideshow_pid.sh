#!/bin/bash

# Write the PID of the script to a file for later retrieval
echo $$ > /tmp/wallpaper_slideshow_pid

# Clean up the PID file on exit
trap 'rm -f /tmp/wallpaper_slideshow_pid' EXIT

# Set the paths to all wallpaper directories
wallpapersDirs=(
    "$HOME/Pictures/newpc/miku/Norded/Twitter"
    "$HOME/Pictures/newpc/miku/Norded"
    "$HOME/Pictures/newpc/miku/cyberpunk nordic"
    "$HOME/Pictures/newpc/miku/explore nord"
    "$HOME/Pictures/newpc/miku/vtuber nord"

)

# Combine all wallpapers from the directories into one array
allWallpapers=()
for dir in "${wallpapersDirs[@]}"; do
    if [ -d "$dir" ]; then
        allWallpapers+=("$dir"/*)
    fi
done

# Log to see exactly what's going on
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /tmp/wallpaper_slideshow.log
}

# Function to shuffle wallpapers using the Fisher-Yates algorithm
shuffle_wallpapers() {
    local i j temp
    for ((i = ${#allWallpapers[@]} - 1; i > 0; i--)); do
        j=$((RANDOM % (i + 1)))
        temp=${allWallpapers[i]}
        allWallpapers[i]=${allWallpapers[j]}
        allWallpapers[j]=$temp
    done
}

# Shuffle the wallpapers array initially
shuffle_wallpapers

# Initialize the index for the wallpaper
currentIndex=0

# Function to change the wallpaper based on the current index
change_wallpaper() {
    selectedWallpaper="${allWallpapers[$currentIndex]}"
    log_message "Changing wallpaper to: $selectedWallpaper"
    # Apply the wallpaper
    swww img --fill-color 3b4252 --resize crop -f CatmullRom --transition-type grow --transition-pos 0.854,0.977 --transition-step 90 --transition-fps 60 "$selectedWallpaper"
}

# Function to move to the next wallpaper
next_wallpaper() {
    currentIndex=$(( (currentIndex + 1) % ${#allWallpapers[@]} ))
    log_message "Switching to next wallpaper: ${allWallpapers[$currentIndex]}"
    change_wallpaper
}

# Function to move to the previous wallpaper
prev_wallpaper() {
    currentIndex=$(( (currentIndex - 1 + ${#allWallpapers[@]}) % ${#allWallpapers[@]} ))
    log_message "Switching to previous wallpaper: ${allWallpapers[$currentIndex]}"
    change_wallpaper
}

# Start by changing to the first wallpaper
log_message "Starting with the shuffled wallpaper list. First index: $currentIndex"
change_wallpaper

# Trap signals for next and previous wallpaper actions
trap 'log_message "Next wallpaper signal received"; next_wallpaper' SIGUSR1
trap 'log_message "Previous wallpaper signal received"; prev_wallpaper' SIGUSR2

# Infinite loop to wait for the next command
while true; do
    log_message "Sleeping for 4 minutes before the next wallpaper change"
    sleep 240 &  # Sleep in the background
    wait $!  # Wait for the sleep to finish or a signal to be caught
    # Check if a signal was received
    if [ $? -eq 0 ]; then
        # No signal received, change to next wallpaper
        next_wallpaper
    fi
done
