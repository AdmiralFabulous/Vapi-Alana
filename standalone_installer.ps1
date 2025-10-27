@"
# ============================================
# Audio Recorder - Standalone Installer
# ============================================
# This script will install everything needed
# Run as Administrator in PowerShell
# ============================================

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Audio Recorder - Quick Install" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
`$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not `$isAdmin) {
    Write-Host "ERROR: Must run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit
}

# Check Python
Write-Host "[1/6] Checking Python..." -ForegroundColor Yellow
try {
    `$pythonVersion = python --version 2>&1
    Write-Host "  Found: `$pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Python not found!" -ForegroundColor Red
    Write-Host "  Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
    pause
    exit
}

# Create requirements.txt
Write-Host ""
Write-Host "[2/6] Creating requirements file..." -ForegroundColor Yellow
@"
sounddevice==0.4.6
numpy==1.24.3
pystray==0.19.5
Pillow==10.2.0
keyboard==0.13.5
"@ | Out-File -FilePath "requirements.txt" -Encoding ASCII
Write-Host "  Created requirements.txt" -ForegroundColor Green

# Install dependencies
Write-Host ""
Write-Host "[3/6] Installing dependencies (this may take a minute)..." -ForegroundColor Yellow
pip install -r requirements.txt --quiet
if (`$LASTEXITCODE -eq 0) {
    Write-Host "  Installed all dependencies" -ForegroundColor Green
} else {
    Write-Host "  ERROR: Failed to install dependencies" -ForegroundColor Red
    pause
    exit
}

# Create audio_recorder.py
Write-Host ""
Write-Host "[4/6] Creating audio recorder application..." -ForegroundColor Yellow
@"
import sounddevice as sd
import wave
import threading
import tkinter as tk
from tkinter import ttk
import pystray
from PIL import Image, ImageDraw, ImageFont
import keyboard
from datetime import datetime
import os
import queue
import numpy as np

class AudioRecorder:
    def __init__(self):
        self.is_recording = False
        self.audio_queue = queue.Queue()
        self.recording_thread = None
        self.output_folder = "C:/Programming"
        self.sample_rate = 48000
        self.channels = 2
        self.current_file = None
        self.current_wave = None
        os.makedirs(self.output_folder, exist_ok=True)
        self.setup_gui()
        self.setup_tray()
        keyboard.add_hotkey('shift+win+q', self.show_window)

    def setup_gui(self):
        self.root = tk.Tk()
        self.root.title("Audio Recorder")
        self.root.geometry("400x300")
        self.root.protocol("WM_DELETE_WINDOW", self.hide_window)
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        title = ttk.Label(main_frame, text="Audio Recorder", font=("Arial", 16, "bold"))
        title.grid(row=0, column=0, columnspan=2, pady=10)
        self.status_label = ttk.Label(main_frame, text="Status: Stopped", font=("Arial", 12))
        self.status_label.grid(row=1, column=0, columnspan=2, pady=5)
        self.file_label = ttk.Label(main_frame, text="No file", font=("Arial", 10))
        self.file_label.grid(row=2, column=0, columnspan=2, pady=5)
        self.start_btn = ttk.Button(main_frame, text="Start Recording", command=self.start_recording)
        self.start_btn.grid(row=3, column=0, pady=10, padx=5)
        self.stop_btn = ttk.Button(main_frame, text="Stop Recording", command=self.stop_recording, state=tk.DISABLED)
        self.stop_btn.grid(row=3, column=1, pady=10, padx=5)
        settings_frame = ttk.LabelFrame(main_frame, text="Settings", padding="5")
        settings_frame.grid(row=4, column=0, columnspan=2, pady=10, sticky=(tk.W, tk.E))
        ttk.Label(settings_frame, text=f"Sample Rate: {self.sample_rate} Hz").grid(row=0, column=0, sticky=tk.W)
        ttk.Label(settings_frame, text=f"Channels: {self.channels} (Stereo)").grid(row=1, column=0, sticky=tk.W)
        ttk.Label(settings_frame, text=f"Output: {self.output_folder}").grid(row=2, column=0, sticky=tk.W)
        hide_btn = ttk.Button(main_frame, text="Hide to Tray", command=self.hide_window)
        hide_btn.grid(row=5, column=0, columnspan=2, pady=10)
        self.root.withdraw()

    def setup_tray(self):
        self.icon_active = self.create_icon_image(True)
        self.icon_inactive = self.create_icon_image(False)
        menu = pystray.Menu(
            pystray.MenuItem("Show", self.show_window),
            pystray.MenuItem("Start Recording", self.start_recording_from_tray),
            pystray.MenuItem("Stop Recording", self.stop_recording_from_tray),
            pystray.MenuItem("Exit", self.quit_app)
        )
        self.tray_icon = pystray.Icon("AU", self.icon_inactive, "Audio Recorder", menu)
        tray_thread = threading.Thread(target=self.tray_icon.run, daemon=True)
        tray_thread.start()

    def create_icon_image(self, active=False):
        image = Image.new('RGB', (64, 64), color=(255, 255, 255) if active else (0, 0, 0))
        draw = ImageDraw.Draw(image)
        try:
            font = ImageFont.truetype("arial.ttf", 32)
        except:
            font = ImageFont.load_default()
        text = "AU"
        text_color = (0, 0, 0) if active else (255, 255, 255)
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        position = ((64 - text_width) // 2, (64 - text_height) // 2)
        draw.text(position, text, fill=text_color, font=font)
        return image

    def audio_callback(self, indata, frames, time, status):
        if status:
            print(f"Audio status: {status}")
        self.audio_queue.put(indata.copy())

    def recording_worker(self):
        while self.is_recording:
            try:
                data = self.audio_queue.get(timeout=0.1)
                if self.current_wave:
                    self.current_wave.writeframes((data * 32767).astype(np.int16).tobytes())
            except queue.Empty:
                continue

    def start_recording(self):
        if self.is_recording:
            return
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        filename = f"recording_{timestamp}.wav"
        filepath = os.path.join(self.output_folder, filename)
        self.current_file = filepath
        self.current_wave = wave.open(filepath, 'wb')
        self.current_wave.setnchannels(self.channels)
        self.current_wave.setsampwidth(2)
        self.current_wave.setframerate(self.sample_rate)
        self.is_recording = True
        self.stream = sd.InputStream(
            callback=self.audio_callback,
            channels=self.channels,
            samplerate=self.sample_rate
        )
        self.stream.start()
        self.recording_thread = threading.Thread(target=self.recording_worker, daemon=True)
        self.recording_thread.start()
        self.status_label.config(text="Status: Recording", foreground="red")
        self.file_label.config(text=f"File: {filename}")
        self.start_btn.config(state=tk.DISABLED)
        self.stop_btn.config(state=tk.NORMAL)
        self.tray_icon.icon = self.icon_active
        print(f"Recording started: {filepath}")

    def stop_recording(self):
        if not self.is_recording:
            return
        self.is_recording = False
        self.stream.stop()
        self.stream.close()
        if self.recording_thread:
            self.recording_thread.join(timeout=1.0)
        if self.current_wave:
            self.current_wave.close()
            self.current_wave = None
        self.status_label.config(text="Status: Stopped", foreground="black")
        self.start_btn.config(state=tk.NORMAL)
        self.stop_btn.config(state=tk.DISABLED)
        self.tray_icon.icon = self.icon_inactive
        print(f"Recording stopped: {self.current_file}")

    def start_recording_from_tray(self):
        self.root.after(0, self.start_recording)

    def stop_recording_from_tray(self):
        self.root.after(0, self.stop_recording)

    def show_window(self):
        self.root.after(0, self._show_window)

    def _show_window(self):
        self.root.deiconify()
        self.root.lift()
        self.root.focus_force()

    def hide_window(self):
        self.root.withdraw()

    def quit_app(self):
        self.stop_recording()
        self.tray_icon.stop()
        self.root.quit()

    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    app = AudioRecorder()
    app.run()
"@ | Out-File -FilePath "audio_recorder.py" -Encoding UTF8
Write-Host "  Created audio_recorder.py" -ForegroundColor Green

# Configure power settings
Write-Host ""
Write-Host "[5/6] Configuring power settings (laptop stays awake with lid closed)..." -ForegroundColor Yellow
powercfg /setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0 | Out-Null
powercfg /setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0 | Out-Null
powercfg /setactive SCHEME_CURRENT | Out-Null
Write-Host "  Configured lid-closed behavior" -ForegroundColor Green

# Create output directory
Write-Host ""
Write-Host "[6/6] Creating output directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "C:\Programming" -Force -ErrorAction SilentlyContinue | Out-Null
Write-Host "  Created C:\Programming" -ForegroundColor Green

# All done!
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "   Installation Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Starting Audio Recorder..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Look for the 'AU' icon in your system tray:" -ForegroundColor White
Write-Host "  Black = Not recording" -ForegroundColor White
Write-Host "  White = Recording active" -ForegroundColor White
Write-Host ""
Write-Host "Controls:" -ForegroundColor Cyan
Write-Host "  Right-click AU icon -> Start/Stop Recording" -ForegroundColor White
Write-Host "  Press Shift + Windows + Q to show interface" -ForegroundColor White
Write-Host "  Recordings save to: C:\Programming" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C in this window to stop" -ForegroundColor Yellow
Write-Host ""

# Launch the application
python audio_recorder.py
"@
