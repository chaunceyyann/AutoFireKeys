# Individual Key Toggler

A powerful AutoHotkey v2 script for Diablo IV that provides individual control over skill automation with advanced features like cooldowns and hold modes.

## Features

### Key Controls (1-6)
- **Individual Toggle**: Enable/disable each key independently
- **Custom Intervals**: Set different auto-press rates for each key (in milliseconds)
- **Hold Mode**: Set interval to `0` to hold the key down instead of tapping
- **Cooldown System** (Keys 1-5 only): Prevents automated presses when you manually press the key

### Additional Controls
- **Dodge (Space)**: Automated dodge/evade with configurable interval
- **Left Click**: Automated left mouse click
- **Right Click**: Automated right mouse click

### GUI Features
- Master on/off toggle
- Customizable global hotkey (default: F1)
- Start All / Stop All buttons
- Real-time status display
- Persistent settings while running

## Default Settings

The script comes pre-configured with optimized defaults:

| Key | Enabled | Interval | Cooldown | Description |
|-----|---------|----------|----------|-------------|
| 1 | ❌ | 1000ms | 0ms | Not active by default |
| 2 | ✅ | 770ms | 0ms | Active, ~0.77s cycle |
| 3 | ✅ | 1100ms | 0ms | Active, ~1.1s cycle |
| 4 | ✅ | 205ms | 1020ms | Fast spam with cooldown |
| 5 | ✅ | 198ms | 0ms | Fast spam |
| 6 | ❌ | 1000ms | - | Not active by default |
| Dodge | ✅ | 300ms | - | Active, ~0.3s cycle |
| Left Click | ✅ | 100ms | - | Active, rapid clicking |
| Right Click | ❌ | 100ms | - | Not active by default |

## How to Use

### Basic Usage
1. Run the script (requires AutoHotkey v2.0)
2. Check "Enable Script" in the Master Toggle section
3. The script will start with default settings
4. Press F1 (or your custom hotkey) to toggle the script on/off

### Interval Settings
- **Normal Mode**: Set any value > 0 for automated key tapping at that rate
  - Example: `500` = Press key every 500ms (2 times per second)
- **Hold Mode**: Set to `0` to hold the key down continuously
  - Perfect for channeled skills or movement keys

### Cooldown Feature (Keys 1-5 Only)
The cooldown prevents automated presses after you manually press a key:

- When you manually press a key, automated presses are blocked for the cooldown duration
- This prevents "double-tapping" and ensures proper skill rotation
- Set to `0` to disable cooldown for that key
- **Ignored in Hold Mode** (when interval = 0)

**Example**: Key 4 with cooldown of 1020ms
- You manually press Key 4
- Automated Key 4 presses are blocked for 1020ms
- During this time, Key 5 (198ms interval) fires ~5 times
- This ensures Key 5 always fires between Key 4 presses

### Customizing Settings
1. **Interval**: Change the number in the "Interval" field
2. **Cooldown**: Change the number in the "Cooldown" field (Keys 1-5 only)
3. **Toggle Keys**: Check/uncheck boxes to enable/disable keys
4. Changes take effect immediately when the script is running

### Tips
- Use non-round numbers (like 205, 770) for more natural-feeling automation
- Keys 4 & 5 are configured for fast spam (~5 presses per second)
- Key 4's 1020ms cooldown ensures proper skill rotation with Key 5
- The master toggle hotkey (F1) lets you quickly enable/disable everything

## Technical Details

### Cooldown System
- Uses `$` prefix on hotkeys to prevent feedback loops
- Tracks manual key presses via `A_TickCount`
- Only blocks automated presses, manual presses always work
- Automatically disabled when interval is set to 0 (hold mode)

### Hold Mode
- Sends `{key down}` when enabled
- Sends `{key up}` when disabled
- Automatically releases held keys when script stops
- Cooldown feature is bypassed in hold mode

## Requirements
- AutoHotkey v2.0 or later
- Windows OS

## Disclaimer
This script is for educational purposes. Use responsibly and in accordance with game terms of service.

