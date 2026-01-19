<#
.SYNOPSIS
    Catppuccin Structure + Wallpaper-Tinted Backgrounds
    v5: No more blue-tinted containers.
#>

$StylesPath = "$HOME\.config\yasb\styles.css"
$WalCache   = "$HOME\.cache\wal\colors.json"

# --- HELPER: MIX COLORS (Restored from your original code) ---
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

function Update-YasbTheme {
    param ($ImagePath)
    Write-Host "Updating Theme for: $ImagePath" -ForegroundColor Cyan

    $TempImage = "$env:TEMP\yasb_wal_temp.jpg"
    try { Copy-Item -Path $ImagePath -Destination $TempImage -Force } catch { return }

    wal --backend haishoku -i "$TempImage" -n -q -s

    if (Test-Path $WalCache) {
        $colors = Get-Content $WalCache | ConvertFrom-Json
        
        # 1. Grab Raw Pywal Data
        $bg     = $colors.special.background
        $fg     = $colors.special.foreground
        $accent = $colors.colors.color6

        # 2. Derive Tinted Containers (Mixed with Accent to stop the 'Bluish' look)
        # We blend the background with the accent slightly (15-25%) to warm it up
        $Surface0 = Get-BlendedHex -BaseHex $bg -MixHex $accent -Percent 15
        $Surface1 = Get-BlendedHex -BaseHex $bg -MixHex $accent -Percent 25

        $newRoot = @"
:root {
    /* --- TINTED CATPPUCCIN PALETTE --- */
    --base: #1e1e2e;
    --mantle:      $bg; 
    --crust:       $bg; 
    --text:        $fg;
    --subtext0:    $fg;
    --subtext1:    $fg;
    --surface0:    $Surface0; /* No longer blue, now matches wallpaper accent */
    --surface1:    $Surface1; 
    --surface2:    $Surface1;
    --teal:        $accent;
    --blue:        $accent;
    --red:         $accent;
    --green:       $accent;
    --yellow:      $accent;
    --pink:        $accent;
    --sky:         $accent;
}
"@
        # --- YOUR ORIGINAL SAFE READ/WRITE LOGIC ---
        $contentRead = $false
        $retries = 0
        $cssContent = $null
        while (-not $contentRead -and $retries -lt 5) {
            try {
                $cssContent = Get-Content $StylesPath -Raw -ErrorAction Stop
                if (-not [string]::IsNullOrWhiteSpace($cssContent)) { $contentRead = $true }
            } catch { Start-Sleep -Milliseconds 200; $retries++ }
        }

        if ($cssContent -match "(?s):root\s*\{.*?\}") {
            $updatedCss = $cssContent -replace "(?s):root\s*\{.*?\}", $newRoot
            $TempCSS = "$StylesPath.tmp"
            try {
                Set-Content -Path $TempCSS -Value $updatedCss -Force
                Move-Item -Path $TempCSS -Destination $StylesPath -Force
                Write-Host "SUCCESS: Unified Theme Applied." -ForegroundColor Green
            } catch { Write-Error "Failed to write." }
        }
    }
}

# --- WATCHER LOOP ---
$lastWall = (Get-ItemProperty 'HKCU:\Control Panel\Desktop').WallPaper
Update-YasbTheme $lastWall
while($true) {
    $currWall = (Get-ItemProperty 'HKCU:\Control Panel\Desktop').WallPaper
    if ($currWall -ne $lastWall) { Start-Sleep -Milliseconds 500; Update-YasbTheme $currWall; $lastWall = $currWall }
    Start-Sleep -Seconds 2
}
