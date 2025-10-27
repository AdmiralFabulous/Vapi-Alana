# Quick Start Guide - Audio Recorder

## Get Up and Running in 3 Steps

### Step 1: Install Dependencies
Open Command Prompt or PowerShell as Administrator and run:
```bash
pip install -r requirements.txt
```

### Step 2: Run the Application
Right-click on `run_audio_recorder.bat` and select **"Run as administrator"**

### Step 3: Start Recording
The app will start in the system tray. Look for the black "AU" icon near your clock.

- **Right-click the AU icon** → Select "Start Recording"
- The icon will turn **WHITE** when recording
- Press **Shift + Windows + Q** anytime to show the control panel

## What Happens Next?

Your recordings are automatically saved to:
```
C:/Programming/recording_YYYY-MM-DD_HH-MM-SS.wav
```

Each file is named with the exact date and time when recording started.

## Quick Controls

| Action | Method |
|--------|--------|
| Show interface | Press `Shift + Win + Q` |
| Start recording | Right-click AU icon → Start Recording |
| Stop recording | Right-click AU icon → Stop Recording |
| Exit application | Right-click AU icon → Exit |

## Audio Quality

- **Format:** WAV (uncompressed)
- **Sample Rate:** 48,000 Hz
- **Bit Depth:** 16-bit
- **Channels:** 2 (Stereo)
- **File Size:** ~10 MB per minute

Perfect for capturing clear audio even in poor environments.

## Troubleshooting

**Can't see the system tray icon?**
- Click the ^ arrow in your Windows taskbar to expand hidden icons

**Hotkey not working?**
- Make sure you ran as Administrator
- Try pressing: Shift + Windows Key + Q (all at once)

**No sound being recorded?**
- Check Windows Settings → Privacy → Microphone
- Make sure your microphone is enabled and set as default

## Tips

- Keep the application running in the system tray
- Monitor the icon color: Black = stopped, White = recording
- Each recording is a separate file - stop and start to create multiple files
- Files are uncompressed for maximum quality

---

**Need Help?** See `README_AudioRecorder.md` for detailed documentation.
