# Paper Journal

*A paper-inspired desktop shell with a touch of liquid glass.*

<p align="center">
  <strong>Paper Journal × Liquid Glass</strong>
</p>

<p align="center">
  A custom desktop shell built with <a href="https://quickshell.org/">Quickshell</a> for <a href="https://hypr.land/">Hyprland</a>, designed around soft paper tones, translucent surfaces, and minimal UI.
</p>

---

## Overview

Paper Journal is a personal desktop customization project that explores the intersection of minimalist design and modern desktop functionality.

Inspired by the tactile aesthetics of paper journals and the translucent visual language of liquid glass, it aims to create a desktop experience that feels calm, cohesive, and functional.

## Features

- **Workspace Indicator** — Quick access to Hyprland workspaces.
- **Clock & Date** — A minimal clock capsule displaying the current date and time.
- **System Information** — At-a-glance system statistics.
- **Battery Indicator** — Battery percentage and charging status.
- **Audio Widget** — Audio information and controls.
- **Calendar** — A floating calendar widget.
- **Quick Settings** — A dedicated quick-settings panel.
- **Power Menu** — Lock, log out, suspend, restart, and shut down controls with confirmation dialogs.

## Design Language

The visual identity of Paper Journal revolves around:

| Element | Design |
|---|---|
| Primary palette | Warm paper and cream |
| Accent colours | Muted blue, lavender, terracotta |
| Typography | Minimal and readable |
| Surfaces | Translucent, layered panels |
| Borders | Soft, subtle highlights |
| Geometry | Rounded corners and pill-shaped capsules |

The goal is to maintain visual consistency without sacrificing usability.

## Tech Stack

- **Window Manager:** Hyprland
- **Shell Framework:** Quickshell
- **Language:** QML
- **Configuration:** Lua
- **Operating System:** Arch Linux

## Project Structure

```text
paper-journal/
├── shell.qml
├── Colors.qml
├── Glass.qml
├── qmldir
│
├── components/
│   ├── Workspaces.qml
│   ├── Battery.qml
│   ├── Audio.qml
│   └── SystemStats.qml
│
└── widgets/
    ├── Calendar.qml
    ├── QuickSettings.qml
    ├── WifiNetworks.qml
    ├── BluetoothDevices.qml
    └── PowerMenu.qml
```

## Installation

### Requirements

- Arch Linux
- Hyprland
- Quickshell
- Hyprlock
- Systemd

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/Arima-Kousei-09/paper-journal.git
   ```

2. Create the Quickshell configuration directory:

   ```bash
   mkdir -p ~/.config/quickshell
   ```

3. Copy the project:

   ```bash
   cp -r paper-journal ~/.config/quickshell/
   ```

4. Launch the shell:

   ```bash
   qs -c paper-journal
   ```

### Hyprland Autostart

Add the following to your Hyprland startup configuration:

```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -c paper-journal")
end)
```

## Configuration

The colour palette and shared design properties are defined in `Colors.qml`.

The reusable translucent surface component is defined in `Glass.qml`.

Modify these files to customise the appearance without having to individually restyle every widget.

## Roadmap

- [x] Custom top bar
- [x] Workspace indicator
- [x] Clock and date
- [x] Battery and audio widgets
- [x] Floating calendar
- [x] Quick settings panel
- [x] Power and session menu
- [ ] Refined backdrop blur integration
- [ ] Additional desktop widgets
- [ ] Further animation and interaction refinements

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
