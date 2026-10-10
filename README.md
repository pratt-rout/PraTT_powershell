# pwsh profile

A lightweight PowerShell prompt that reproduces the Oh My Posh **remk** theme without loading Oh My Posh itself.

## What `profile.ps1` does

- **Custom prompt** — displays segments for **user**, **folder**, **git branch**, and **time** (`HH:mm`) using ANSI escape codes and Nerd Font glyphs (diamond / arrow separators).
- **Fast git branch detection** — reads `.git/HEAD` directly (supports worktrees and submodules) instead of spawning `git.exe`, keeping the prompt snappy.
- **`Use-OhMyPosh`** — optional helper that switches to the real Oh My Posh `remk` theme for the current session.
- **Deferred posh-git import** — registers a `PowerShell.OnIdle` event to import `posh-git` in the background, then restores the custom prompt so posh-git's default prompt doesn't take over.

## Requirements

- PowerShell 5.1+ or PowerShell 7+
- A terminal that supports ANSI escapes
- A [Nerd Font](https://www.nerdfonts.com/) for the separator glyphs
- (Optional) [Oh My Posh](https://ohmyposh.dev/) and the `remk` theme for `Use-OhMyPosh`
- (Optional) [posh-git](https://github.com/dahlbyk/posh-git)

## Usage

Dot-source or copy the file into your PowerShell profile:

```powershell
. ~\path\to\profile.ps1
```

Or symlink/copy it to `$PROFILE` so it loads automatically on every session.