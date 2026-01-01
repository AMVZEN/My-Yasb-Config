# 🎨 YASB Auto-Pywal Theme

A dynamic theme configuration for **YASB (Yet Another Status Bar)** that automatically syncs your bar’s color scheme with your current wallpaper using **Pywal**.

This setup uses a custom **PowerShell wallpaper watcher** to generate a **high-contrast, minimal 3-color palette** (Background · Text · Accent) based on your wallpaper—keeping everything readable and aesthetic.

---

## ✨ Features

* 🎯 Automatically updates YASB colors when your wallpaper changes
* 🖼️ Extracts colors directly from the current wallpaper
* 🌑 Forces a clean, high-contrast dark theme
* 🎨 Single accent color for a modern, minimal look
* 🔁 Auto-reloads YASB after applying new colors

---

## ⚠️ Prerequisites

Make sure you have the following installed:

* **YASB** – Status bar
* **Komorebi** – Tiling Window Manager
* **Python** – Required for Pywal
* **ImageMagick** – Required for image processing

---

## 📦 Installation

### 1️⃣ Install Python Dependencies

Open a terminal and run:

```bash
pip install pywal16 haishoku
```

* **pywal16** → Updated fork of Pywal
* **haishoku** → Backend for color extraction

---

### 2️⃣ Copy Configuration Files

Download or clone this repository and place **all files** into your YASB config directory:

```
C:\Users\YOUR_USER\.config\yasb
```

---

### 3️⃣ Configure API Keys & Paths

Open `config.yaml` and update the following:

* 🌦 **Weather Widget**

  * Add your **OpenWeatherMap API key**
* 🕒 **Clock / Time**

  * Adjust formatting if needed
* 🖼️ **Wallpapers**

  * Ensure the wallpaper directory path is correct (if referenced)

---

### 4️⃣ Set Up the Wallpaper Watcher (Auto Theme Updates)

1. Open `LaunchYasb.vbs`
2. Update the path to `yasb_watcher.ps1`

#### Run on Startup

1. Press **Win + R**
2. Type `shell:startup` and press Enter
3. Inside the folder:

   * Right-click → **New > Shortcut**
   * Paste the path to `LaunchYasb.vbs`

     ```
     C:\Users\YOUR_USER\.config\yasb\LaunchYasb.vbs
     ```
4. *(Optional)*

   * Right-click the shortcut → **Properties**
   * Set **Run** to **Minimized** to keep it hidden

---

### 5️⃣ Komorebi Configuration

1. Navigate to the **`komorebi`** folder in this repository
2. Copy the provided configuration files
3. Replace your existing files with these:

   * `komorebi.json`
   * `whkdrc`

> ⚠️ These files are tailored to work seamlessly with this YASB setup. Make sure to back up your originals before replacing.

---

### 6️⃣ Windhawk Configuration

1. Open the **`windhawk`** folder in this repository
2. Follow the instructions provided **inside the files** in that folder

> Windhawk is used for additional Windows-level tweaks required by this setup.

---

## 🧠 How It Works

The `yasb_watcher.ps1` script runs silently in the background and monitors the Windows Registry for wallpaper changes.

When a change is detected:

1. 🖼️ Retrieves the current wallpaper image
2. 🎨 Runs **Pywal** to generate a color palette
3. 🌑 Enforces a **high-contrast dark theme**
4. 🎯 Picks a single dominant accent color
5. ✍️ Injects colors into `styles.css`
6. 🔄 Reloads YASB automatically

---

## 📝 Known Issues / Notes

* ⚠️ **CSS Locking**

  * YASB may occasionally lock `styles.css` during reload
  * The script retries automatically—if it doesn’t update, wait a moment or change the wallpaper again
* 🎨 **Intentional Minimalism**

  * “Rainbow” Pywal colors are ignored
  * Theme is forced into a **3-color system** for readability and consistency

---

## ❤️ Credits

* **YASB** — Amr Ismail
* **Pywal16** — Eyzi
