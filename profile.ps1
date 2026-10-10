# --- Prompt that reproduces the Oh My Posh "remk" theme without loading Oh My Posh ---
# Segments: user | folder | git(branch) | HH:mm.  Colors/shapes copied from remk.omp.json.

function global:prompt {
    $exit = $?
    $e   = [char]27
    $rst = "$e[0m"
    $lDia = [char]0xE0B6   # leading diamond
    $arrow = [char]0xE0B0  # trailing diamond

    # 4-bit bright backgrounds used by the theme (lightMagenta/Yellow/Cyan/Green)
    $bgMag = "$e[105m"; $bgYel = "$e[103m"; $bgCya = "$e[106m"; $bgGrn = "$e[102m"
    $fgMag = "$e[95m";  $fgGrn = "$e[92m"
    $white = "$e[38;2;255;255;255m"; $dark = "$e[38;2;63;63;63m"

    # folder (style: folder)
    $loc = $executionContext.SessionState.Path.CurrentLocation
    $path = $loc.Path
    $folder = if ($path -eq $HOME) { '~' }
              elseif ($loc.Provider.Name -ne 'FileSystem') { $path }
              else { $leaf = Split-Path $path -Leaf; if ($leaf) { $leaf } else { $path.TrimEnd('\') } }

    # git branch read straight from .git/HEAD (no git.exe spawn)
    $head = $null
    if ($loc.Provider.Name -eq 'FileSystem') {
        $dir = $path
        while ($dir) {
            $g = Join-Path $dir '.git'
            if (Test-Path -LiteralPath $g) {
                if (Test-Path -LiteralPath $g -PathType Leaf) {   # worktree / submodule pointer file
                    $m = [regex]::Match((Get-Content -LiteralPath $g -TotalCount 1), '^gitdir:\s*(.+)$')
                    $g = if ($m.Success) { Join-Path $dir $m.Groups[1].Value.Trim() } else { $null }
                }
                $hf = if ($g) { Join-Path $g 'HEAD' }
                if ($hf -and (Test-Path -LiteralPath $hf)) {
                    $h = (Get-Content -LiteralPath $hf -TotalCount 1).Trim()
                    $head = if ($h -like 'ref:*') { $h -replace '^ref:\s*refs/heads/', '' } else { $h.Substring(0, [Math]::Min(7, $h.Length)) }
                }
                break
            }
            $parent = Split-Path $dir -Parent
            if ($parent -eq $dir) { break }
            $dir = $parent
        }
    }

    $out  = "$fgMag$lDia$rst"
    $out += "$bgMag$white$env:USERNAME $rst"
    $out += "$bgYel$dark $folder $rst"
    if ($head) { $out += "$bgCya$white git($head) $rst" }
    $out += "$bgGrn$white $(Get-Date -Format 'HH:mm') $rst"
    $out += "$fgGrn$arrow$rst "
    $out
}
$global:__themePrompt = $function:prompt

# --- Opt in to the real Oh My Posh for this session: run  Use-OhMyPosh ---
function global:Use-OhMyPosh {
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\remk.omp.json" | Invoke-Expression
}

# --- posh-git: defer until idle, then put our prompt back (posh-git swaps the prompt on import) ---
$null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    Import-Module posh-git -Global
    Set-Item -Path Function:\global:prompt -Value $global:__themePrompt
}
