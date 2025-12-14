<#
.SYNOPSIS
    Watches for Windows Wallpaper changes, runs Pywal, and updates YASB styles.
    v3: SAFE WRITE MODE (Prevents empty styles.css)
#>

# --- CONFIGURATION ---
$StylesPath = "$HOME\.config\yasb\styles.css"
$WalCache   = "$HOME\.cache\wal\colors.json"

# --- HELPER: MIX COLORS ---
function Get-BlendedHex {
    param ([string]$BaseHex, [string]$MixHex, [int]$Percent)
    $c1 = $BaseHex.TrimStart('#'); $c2 = $MixHex.TrimStart('#')
    $r1 = [Convert]::ToInt32($c1.Substring(0,2), 16); $g1 = [Convert]::ToInt32($c1.Substring(2,2), 16); $b1 = [Convert]::ToInt32($c1.Substring(4,2), 16)
    $r2 = [Convert]::ToInt32($c2.Substring(0,2), 16); $g2 = [Convert]::ToInt32($c2.Substring(2,2), 16); $b2 = [Convert]::ToInt32($c2.Substring(4,2), 16)
    $rNew = [int][Math]::Round($r1 + ($r2 - $r1) * ($Percent / 100))
    $gNew = [int][Math]::Round($g1 + ($g2 - $g1) * ($Percent / 100))
    $bNew = [int][Math]::Round($b1 + ($b2 - $b1) * ($Percent / 100))
    return "#{0:X2}{1:X2}{2:X2}" -f $rNew, $gNew, $bNew
}

# --- MAIN FUNCTION ---
function Update-YasbTheme {
    param ($ImagePath)
    Write-Host "Wallpaper detected: $ImagePath" -ForegroundColor Cyan

    $TempImage = "$env:TEMP\yasb_wal_temp.jpg"
    try { Copy-Item -Path $ImagePath -Destination $TempImage -Force } catch { return }

    # Run Pywal
    wal --backend haishoku -i "$TempImage" -n -q -s

    if (Test-Path $WalCache) {
        $colors = Get-Content $WalCache | ConvertFrom-Json
        
        $bg = $colors.special.background
        $fg = $colors.special.foreground
        $MainAccent = $colors.colors.color6 
        $SecAccent  = $colors.colors.color4

        try {
            $Surface0 = Get-BlendedHex -BaseHex $bg -MixHex $fg -Percent 12
            $Surface1 = Get-BlendedHex -BaseHex $bg -MixHex $fg -Percent 20
            $Mantle   = Get-BlendedHex -BaseHex $bg -MixHex $fg -Percent 5
        } catch {
            $Surface0 = $colors.colors.color8; $Surface1 = $colors.colors.color8; $Mantle = $bg
        }

        $newRoot = @"
:root {
    /* --- UNIFIED CLEAN PALETTE --- */
    --base:       $bg;
    --mantle:     $Mantle; 
    --crust:      $bg; 
    --text:       $fg;
    --subtext0:   $fg;
    --subtext1:   $fg;
    --surface0:   $Surface0;
    --surface1:   $Surface1; 
    --surface2:   $Surface1;
    --overlay0:   $Surface1;
    --overlay1:   $fg;
    --overlay2:   $fg;
    --red:        $MainAccent;
    --green:      $MainAccent;
    --yellow:     $MainAccent;
    --blue:       $SecAccent;
    --mauve:      $SecAccent;
    --teal:       $MainAccent;
    --lavender:   $SecAccent;
    --rosewater:  $MainAccent;
    --flamingo:   $MainAccent;
    --pink:       $MainAccent;
    --maroon:     $MainAccent;
    --peach:      $MainAccent;
    --sky:        $SecAccent;
    --sapphire:   $SecAccent;
}
"@
        # --- SAFE READ LOGIC ---
        # Retry reading up to 5 times if file is locked or returns empty
        $contentRead = $false
        $retries = 0
        $cssContent = $null

        while (-not $contentRead -and $retries -lt 5) {
            try {
                $cssContent = Get-Content $StylesPath -Raw -ErrorAction Stop
                if (-not [string]::IsNullOrWhiteSpace($cssContent)) {
                    $contentRead = $true
                } else {
                    throw "Empty content"
                }
            } catch {
                Write-Warning "Could not read CSS (locked or empty). Retrying..."
                Start-Sleep -Milliseconds 200
                $retries++
            }
        }

        # ABORT if we still don't have content (Prevents wiping the file)
        if (-not $contentRead) {
            Write-Error "CRITICAL: Could not read styles.css. Update aborted to prevent data loss."
            return
        }

        if ($cssContent -match "(?s):root\s*\{.*?\}") {
            $updatedCss = $cssContent -replace "(?s):root\s*\{.*?\}", $newRoot
            
            # --- SAFE WRITE LOGIC ---
            # Write to a .tmp file first, then Move-Item. 
            # This ensures we never perform a partial write to the real file.
            $TempCSS = "$StylesPath.tmp"
            
            try {
                Set-Content -Path $TempCSS -Value $updatedCss -Force
                Move-Item -Path $TempCSS -Destination $StylesPath -Force
                Write-Host "SUCCESS: YASB updated cleanly." -ForegroundColor Green
            } catch {
                Write-Error "Failed to write CSS file. YASB might be locking it tightly."
            }
        }
    }
}

# --- WATCHER LOOP ---
Write-Host "Monitoring..." -ForegroundColor Magenta
$lastWall = (Get-ItemProperty 'HKCU:\Control Panel\Desktop').WallPaper
Update-YasbTheme $lastWall

while($true) {
    $currWall = (Get-ItemProperty 'HKCU:\Control Panel\Desktop').WallPaper
    if ($currWall -ne $lastWall) {
         Start-Sleep -Milliseconds 500 
         Update-YasbTheme $currWall
         $lastWall = $currWall
    }
    Start-Sleep -Seconds 2
}