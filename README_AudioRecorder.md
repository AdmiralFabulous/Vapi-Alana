# Windows Audio Recorder

A system tray audio recording application for Windows that continuously records high-quality stereo audio.

## Features

- System tray application with "AU" icon
- White icon when recording, black when inactive
- High-quality stereo audio recording (48kHz, 16-bit WAV)
- Automatic file naming with date and time
- Global hotkey: `Shift + Windows + Q` to show interface
- Saves to `C:/Programming`

## Installation

### Prerequisites

- Python 3.8 or higher
- Windows 10 or higher
- Administrator privileges (required for global hotkey)

### Setup Steps

1. **Install Python dependencies:**
```bash
pip install -r requirements.txt
```

2. **Create output directory:**
The application will automatically create `C:/Programming` if it doesn't exist.

## Usage

### Running the Application

**Option 1: Using Python directly**
```bash
python audio_recorder.py
```

**Option 2: Using the batch file (Windows)**
```bash
run_audio_recorder.bat
```

### Running as Administrator

To enable the global hotkey (Shift+Windows+Q), you must run the application as administrator:

1. Right-click on `run_audio_recorder.bat`
2. Select "Run as administrator"

Or for Python directly:
1. Open Command Prompt as administrator
2. Navigate to the directory
3. Run `python audio_recorder.py`

### Controls

- **Show Interface:** Press `Shift + Windows + Q`
- **System Tray:** Right-click the "AU" icon for menu options
- **Start Recording:** Click "Start Recording" button or use tray menu
- **Stop Recording:** Click "Stop Recording" button or use tray menu
- **Hide to Tray:** Close the window or click "Hide to Tray"

### Icon States

- **White "AU" icon:** Recording is active
- **Black "AU" icon:** Recording is inactive

## Output Files

Audio files are saved to `C:/Programming` with the following format:
- Filename: `recording_YYYY-MM-DD_HH-MM-SS.wav`
- Format: WAV (uncompressed)
- Quality: 48kHz, 16-bit, Stereo
- Example: `recording_2025-10-27_14-30-45.wav`

## Troubleshooting

### Global Hotkey Not Working

- Make sure you're running the application as administrator
- Check if another application is using the same hotkey combination

### No Audio Recording

- Check Windows sound settings and ensure microphone is enabled
- Verify microphone permissions in Windows Privacy settings
- Try selecting a different audio input device in Windows settings

### Missing Dependencies

If you encounter import errors, reinstall dependencies:
```bash
pip install --upgrade -r requirements.txt
```

### Permission Error for C:/Programming

The application will try to create the folder automatically. If it fails:
1. Manually create `C:/Programming` folder
2. Ensure you have write permissions
3. Or run the application as administrator

## Keep Recording with Laptop Lid Closed

By default, most laptops sleep when you close the lid, which stops recording. To keep recording with the lid closed:

### Quick Fix (PowerShell One-Liner)

Open **PowerShell as Administrator** and run:

```powershell
powercfg /setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0; powercfg /setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0; powercfg /setactive SCHEME_CURRENT
```

### Or Use the Included Script

Run `configure_lid_settings.ps1` as Administrator for a guided configuration.

### Important Notes for Lid-Closed Operation

- **Keep laptop plugged in** for long recordings
- **Ensure proper ventilation** - place on hard, flat surface
- Screen turns off but system stays fully awake
- Battery drains faster if running on battery power
- Laptop may get warmer with lid closed

## Auto-Start on Windows Boot (Optional)

To have the application start automatically when Windows boots:

1. Press `Win + R`
2. Type `shell:startup` and press Enter
3. Create a shortcut to `run_audio_recorder.bat` in this folder
4. Right-click the shortcut → Properties → Advanced
5. Check "Run as administrator"

## System Requirements

- Windows 10 or higher
- Python 3.8+
- At least 1GB free disk space for recordings
- Working microphone

## Notes

- WAV files are uncompressed for maximum quality
- File sizes: Approximately 10MB per minute of stereo recording
- The application runs in the background and uses minimal resources when idle
- Recording continues until manually stopped
