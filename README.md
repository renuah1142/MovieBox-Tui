# Vincymovie

Vincymovie is the Windows-focused rebrand of this project. It keeps the original Rust application core and its local-player architecture, while producing a `Vincymovie.exe` desktop-friendly terminal application.

## Windows quick install

After the first successful Windows build has been published by GitHub Actions, install the latest Vincymovie build with PowerShell:

```powershell
irm https://raw.githubusercontent.com/renuah1142/MovieBox-Tui/main/vincymovie-install.ps1 | iex
```

The installer downloads the packaged Windows x64 application, verifies its SHA-256 checksum when available, and installs it under `%LOCALAPPDATA%\\Programs\\Vincymovie\\bin`.

Run it with:

```powershell
vincymovie
```

or launch `%LOCALAPPDATA%\\Programs\\Vincymovie\\bin\\Vincymovie.exe` directly.

No Rust or Cargo installation is required on a normal end-user machine. The GitHub Actions build produces the self-contained application binary; playback still uses a supported local media player configured by the application.

## What Vincymovie is built around

- Search and browse the project's provider-backed catalogue.
- Movie and TV-series details.
- Seasons and episodes for series.
- Live-TV/IPTV playlist support using playlists supplied by the user.
- Local playback through supported media players.
- Local settings, cache, favourites, history, subtitles, and themes from the existing Rust core.

## Development

The source remains a Rust project. The Windows release workflow builds `vincymovie.exe` on GitHub's Windows runner and packages it as `Vincymovie_Windows_x64.zip`.

```powershell
cargo build --release --bin vincymovie
```

The original project documentation and source structure remain in the repository for contributors who want to work on the Rust core.
