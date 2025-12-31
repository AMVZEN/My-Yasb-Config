YASB Auto-Pywal Theme
This is a configuration for YASB (Yet Another Status Bar) that automatically updates your bar's color scheme to match your current wallpaper using Pywal. It uses a custom PowerShell watcher to generate a high-contrast, clean 3-color palette based on your background image.

⚠ Prerequisites
Before installing, ensure you have the following installed on your machine:

YASB (The status bar itself).
Komorebi (Tiling Window Manager).
Python (Required for Pywal).
ImageMagick (Required for image processing).
📦 Installation
1. Install Python Dependencies
Open your terminal and install pywal16 (an updated fork of pywal) and haishoku (the backend used for color generation):

Bash

pip install pywal16 haishoku
2. Copy Configuration Files
Download this repository and place all files into your YASB configuration directory:

Location: C:\Users\YOUR_USER\.config\yasb\
3. Configure API Keys & Paths
Open config.yaml in a text editor and update the following:

Weather Widget: Add your OpenWeatherMap API key.
Clock/Time: Adjust formatting if necessary.
Wallpapers: Ensure your wallpaper folder path is correct (if referenced in the config).
4. Set Up the Wallpaper Watcher
Open LaunchYasb.vbs and change the path to your yasb_watcher.ps1
To make the theme change automatically when you change your wallpaper, you need to run the PowerShell script on startup.

Press Win + R, type shell:startup, and hit Enter.
Right-click inside the folder > New > Shortcut.
Paste the path to the LaunchYasb.vbs file (e.g., C:\Users\YOUR_USER\.config\yasb\LaunchYasb.vbs).
(Optional) Right-click the new shortcut > Properties > Change "Run" to Minimized to hide the window.
🎨 How it Works
The yasb_watcher.ps1 script runs in the background and monitors the Windows Registry for wallpaper changes. When a change is detected:

It grabs the current wallpaper image.
It runs pywal to generate a color palette.
It calculates a High Contrast theme (forcing a dark background and a single dominant accent color).
It safely injects these colors into styles.css and reloads YASB.
📝 Known Issues / Notes
It's a bit wonky: Sometimes YASB locks the CSS file while it's trying to reload. The script has a retry mechanism, but if colors don't update immediately, give it a second or change the wallpaper again.
Contrast: The script is hard-coded to ignore the "rainbow" colors Pywal generates and instead forces a clean 3-color look (Background, Text, Accent) to ensure widgets are always readable.
Credits
YASB by Amr Ismail
Pywal16 by Eyzi

Its all vibecoded
