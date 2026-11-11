# Paper Journal

*A paper-inspired desktop shell with a touch of Liquid Glass.*

<p align="center">
  <strong>Paper Journal × Liquid Glass</strong>
</p>

<p align="center">
  A custom desktop shell built with <a href="https://quickshell.org/">Quickshell</a> for <a href="https://hypr.land/">Hyprland</a>, combining warm paper-inspired aesthetics, translucent surfaces, and functional desktop widgets.
</p>

---

## Overview

Paper Journal is a personal desktop customization project exploring the intersection of minimalist design and modern desktop functionality.

Inspired by the tactile aesthetics of paper journals, editorial layouts, coffeehouse interiors, and the translucent visual language of Liquid Glass, it aims to create a desktop environment that feels calm, cohesive, and functional.

Rather than relying on a collection of unrelated widgets, Paper Journal uses a shared visual language and reusable components to create a consistent desktop experience.

## Features

### Desktop Interface

- **Custom Top Bar** — A floating glass-inspired panel containing workspaces, clock, system information, battery, audio, and desktop controls.
- **Workspace Indicator** — Visual representation of active Hyprland workspaces.
- **Clock & Date** — Minimal clock capsule displaying the current date and time.
- **System Statistics** — At-a-glance system information.
- **Battery Indicator** — Battery percentage and charging status.
- **Audio Widget** — Audio information and controls.
- **Auto-hiding Dock** — A floating application dock that reveals itself when approached and hides when not in use.

### Desktop Widgets

- **Calendar** — A floating calendar panel.
- **Quick Settings** — A centralized panel for desktop settings.
- **Wi-Fi Networks** — Network discovery and selection interface.
- **Bluetooth Devices** — Bluetooth device interface.
- **Power Menu** — Lock, log out, suspend, restart, and shut down controls with confirmation dialogs.

### Notifications

- **Notification Center** — A centralized notification history with application grouping.
- **Custom Notification Toasts** — Floating notifications with automatic dismissal and a queue.
- **Do Not Disturb** — Suppresses custom notification toasts while retaining notification history.
- **Notification Management** — Clear individual notifications or dismiss the entire history.

### Git Integration

- **Git History** — Browse recent commits, authors, timestamps, hashes, and commit details.
- **Working Tree** — Inspect staged, modified, deleted, renamed, and untracked files.
- **Branch Tracking** — View the current branch and upstream ahead/behind status.
- **GitHub Branding** — Local Octocat SVG integrated into the interface.

The Git panel is designed as a read-only repository inspector. It does not automatically stage, commit, or push changes.

## Design Language

The visual identity of Paper Journal revolves around:

| Element | Design |
|---|---|
| Primary palette | Warm paper, cream, and parchment |
| Accent colours | Muted blue, lavender, terracotta |
| Typography | Minimal and readable |
| Surfaces | Translucent, layered glass panels |
| Borders | Soft highlights and subtle outlines |
| Geometry | Rounded corners and pill-shaped capsules |
| Inspiration | Paper journals, editorial layouts, Liquid Glass |

The goal is to maintain visual consistency without sacrificing usability.

### Colour Palette

The shared palette is defined in `Colors.qml`.

- Paper: `#E8E1D6`
- Paper Light: `#F3EEE6`
- Muted Blue: `#91AFC4`
- Lavender: `#B7A6C9`
- Terracotta: `#C69B82`
- Ink: `#34495E`

## Tech Stack

- **Operating System:** Arch Linux
- **Window Manager:** Hyprland
- **Shell Framework:** Quickshell
- **UI Language:** QML
- **Configuration Language:** Lua
- **Graphics Toolkit:** Qt Quick
- **Notification Interface:** Quickshell Notification Service
- **Version Control:** Git

## Project Structure

```text
paper-journal/
├── shell.qml
├── Colors.qml
├── Glass.qml
├── qmldir
│
├── assets/
│   └── github-mark.svg
│
├── components/
│   ├── Workspaces.qml
│   ├── Battery.qml
│   ├── Audio.qml
│   ├── SystemStats.qml
│   └── DockItem.qml
│
├── services/
│   └── NotificationService.qml
│
├── widgets/
│   ├── Calendar.qml
│   ├── QuickSettings.qml
│   ├── WifiNetworks.qml
│   ├── BluetoothDevices.qml
│   ├── PowerMenu.qml
│   ├── Dock.qml
│   ├── NotificationCenter.qml
│   ├── NotificationToast.qml
│   └── GitHistory.qml
│
└── calendar-test/
    ├── Calendar.qml
    └── shell.qml
```

## Installation

### Requirements

- Arch Linux
- Hyprland
- Quickshell
- Hyprlock
- Git
- Systemd

Additional utilities may be required depending on the functionality enabled in individual widgets.

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/Arima-Kousei-09/paper-journal.git
   ```

2. Create the Quickshell configuration directory:

   ```bash
   mkdir -p ~/.config/quickshell
   ```

3. Move the repository into the configuration directory:

   ```bash
   cp -r paper-journal ~/.config/quickshell/
   ```

4. Launch Paper Journal:

   ```bash
   qs -c paper-journal
   ```

### Hyprland Autostart

Paper Journal can be launched automatically when Hyprland starts.

Add the following to your Hyprland Lua configuration:

```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("qs -c paper-journal")
end)
```

## Configuration

### Colours

The shared colour palette, corner radii, and other design properties are defined in:

```text
Colors.qml
```

### Glass Surfaces

The reusable glass component is defined in:

```text
Glass.qml
```

It provides translucent backgrounds, layered highlights, borders, and subtle reflections.

### Widgets

Individual widgets are organized under:

```text
widgets/
```

Reusable desktop components are organized under:

```text
components/
```

### Notifications

Notification handling and history management are defined in:

```text
services/NotificationService.qml
```

### Git Panel

The Git dashboard is implemented in:

```text
widgets/GitHistory.qml
```

The current implementation uses a local repository path. If installing the project elsewhere, update the `repositoryPath` property and the GitHub SVG asset path accordingly.

## Running and Reloading

Launch the shell:

```bash
qs -c paper-journal
```

Restart Quickshell after making changes:

```bash
pkill -x qs
qs -c paper-journal
```

## Acknowledgements

Built with:

- [Quickshell](https://quickshell.org/)
- [Hyprland](https://hypr.land/)
- [Qt / QML](https://www.qt.io/)

---

<p align="center">
  <i>Designed to feel like a quiet page in an otherwise noisy digital world.</i>
</p>

<p align="center">
  Made with curiosity, caffeine, and questionable sleep schedules.
</p>

