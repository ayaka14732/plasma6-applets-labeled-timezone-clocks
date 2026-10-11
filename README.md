# Labeled Time Zone Clocks

Labeled Time Zone Clocks is a multi-time-zone clock widget for KDE Plasma 6 panels. A single widget instance can display multiple clocks, each with its own label and time zone.

## Features

- Add, remove, and reorder up to 32 clocks
- Assign a custom label and standard IANA time zone to each clock
- Handle daylight saving time automatically
- Click the clocks to open a month calendar, with previous/next month navigation and a Today button
- Use the regional default, 24-hour, or 12-hour time format
- Configure everything through the standard Plasma widget settings interface
- Install, upgrade, and remove the widget with the Arch Linux package manager

A newly added widget initially displays only the local time.

Left-click any clock to open or close the calendar. Use its left and right arrows to browse months, or **Today** to return to the current month. Each time you reopen the calendar it shows the current month in the system time zone. Clicking outside the popup or pressing **Esc** closes it. The widget behaves the same way when placed on the desktop. The calendar does not show holidays or events.

## Installation

Run the following command from this directory:

```bash
makepkg -si
```

This builds an Arch Linux package, asks pacman to install any missing dependencies, and installs the widget system-wide at:

```text
/usr/share/plasma/plasmoids/local.labeledtimezoneclock/
```

After installation, enter panel edit mode and add **Labeled Time Zone Clocks**. If the widget does not appear in the list immediately, log out of the Plasma session and log back in.

## Configuration

Right-click the widget, select **Configure Labeled Time Zone Clocks…**, and add the clocks you want. For example:

- Label `SFO`, time zone `America/Los_Angeles`
- Label `LTN`, time zone `Europe/London`
- Label `ZRH`, time zone `Europe/Zurich`
- Label `HKG`, time zone `Asia/Hong_Kong`

Select **Apply** to save the settings. Plasma stores the configuration separately for each widget instance. The widget does not create or manage any additional user configuration files.

## Updating

After obtaining a newer version of the source, run:

```bash
makepkg -si
```

Pacman will upgrade the package with the same name. The stable widget ID, `local.labeledtimezoneclock`, allows Plasma to preserve existing widget instances and their settings across upgrades.

## Uninstallation

Remove the widget from the panel, then run:

```bash
sudo pacman -Rns plasma6-applets-labeled-timezone-clocks
```

Pacman will remove the packaged files. No additional cleanup is required because the widget does not create a separate user configuration file.

## Compatibility

The widget requires KDE Plasma 6.7 or later; it was developed and tested against the `org.kde.plasma.clock` interface provided by Plasma 6.7. It does not access external network services or execute shell commands.
