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
        self.sample_rate = 48000  # High quality
        self.channels = 2  # Stereo
        self.current_file = None
        self.current_wave = None

        # Create output folder if it doesn't exist
        os.makedirs(self.output_folder, exist_ok=True)

        # Setup GUI
        self.setup_gui()

        # Setup system tray
        self.setup_tray()

        # Register global hotkey (Shift+Windows+Q)
        keyboard.add_hotkey('shift+win+q', self.show_window)

    def setup_gui(self):
        """Setup the main GUI window"""
        self.root = tk.Tk()
        self.root.title("Audio Recorder")
        self.root.geometry("400x300")
        self.root.protocol("WM_DELETE_WINDOW", self.hide_window)

        # Main frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # Title
        title = ttk.Label(main_frame, text="Audio Recorder", font=("Arial", 16, "bold"))
        title.grid(row=0, column=0, columnspan=2, pady=10)

        # Status
        self.status_label = ttk.Label(main_frame, text="Status: Stopped", font=("Arial", 12))
        self.status_label.grid(row=1, column=0, columnspan=2, pady=5)

        # Current file
        self.file_label = ttk.Label(main_frame, text="No file", font=("Arial", 10))
        self.file_label.grid(row=2, column=0, columnspan=2, pady=5)

        # Control buttons
        self.start_btn = ttk.Button(main_frame, text="Start Recording", command=self.start_recording)
        self.start_btn.grid(row=3, column=0, pady=10, padx=5)

        self.stop_btn = ttk.Button(main_frame, text="Stop Recording", command=self.stop_recording, state=tk.DISABLED)
        self.stop_btn.grid(row=3, column=1, pady=10, padx=5)

        # Settings
        settings_frame = ttk.LabelFrame(main_frame, text="Settings", padding="5")
        settings_frame.grid(row=4, column=0, columnspan=2, pady=10, sticky=(tk.W, tk.E))

        ttk.Label(settings_frame, text=f"Sample Rate: {self.sample_rate} Hz").grid(row=0, column=0, sticky=tk.W)
        ttk.Label(settings_frame, text=f"Channels: {self.channels} (Stereo)").grid(row=1, column=0, sticky=tk.W)
        ttk.Label(settings_frame, text=f"Output: {self.output_folder}").grid(row=2, column=0, sticky=tk.W)

        # Hide button
        hide_btn = ttk.Button(main_frame, text="Hide to Tray", command=self.hide_window)
        hide_btn.grid(row=5, column=0, columnspan=2, pady=10)

        # Start hidden
        self.root.withdraw()

    def setup_tray(self):
        """Setup system tray icon"""
        # Create icon image
        self.icon_active = self.create_icon_image(True)
        self.icon_inactive = self.create_icon_image(False)

        # Create menu
        menu = pystray.Menu(
            pystray.MenuItem("Show", self.show_window),
            pystray.MenuItem("Start Recording", self.start_recording_from_tray),
            pystray.MenuItem("Stop Recording", self.stop_recording_from_tray),
            pystray.MenuItem("Exit", self.quit_app)
        )

        # Create tray icon
        self.tray_icon = pystray.Icon("AU", self.icon_inactive, "Audio Recorder", menu)

        # Run tray icon in separate thread
        tray_thread = threading.Thread(target=self.tray_icon.run, daemon=True)
        tray_thread.start()

    def create_icon_image(self, active=False):
        """Create system tray icon with 'AU' text"""
        # Create image
        image = Image.new('RGB', (64, 64), color=(255, 255, 255) if active else (0, 0, 0))
        draw = ImageDraw.Draw(image)

        # Draw text
        try:
            font = ImageFont.truetype("arial.ttf", 32)
        except:
            font = ImageFont.load_default()

        text = "AU"
        text_color = (0, 0, 0) if active else (255, 255, 255)

        # Get text bounding box for centering
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]

        position = ((64 - text_width) // 2, (64 - text_height) // 2)
        draw.text(position, text, fill=text_color, font=font)

        return image

    def audio_callback(self, indata, frames, time, status):
        """Callback for audio recording"""
        if status:
            print(f"Audio status: {status}")
        self.audio_queue.put(indata.copy())

    def recording_worker(self):
        """Worker thread for writing audio data"""
        while self.is_recording:
            try:
                data = self.audio_queue.get(timeout=0.1)
                if self.current_wave:
                    self.current_wave.writeframes((data * 32767).astype(np.int16).tobytes())
            except queue.Empty:
                continue

    def start_recording(self):
        """Start audio recording"""
        if self.is_recording:
            return

        # Generate filename with timestamp
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        filename = f"recording_{timestamp}.wav"
        filepath = os.path.join(self.output_folder, filename)

        # Open WAV file
        self.current_file = filepath
        self.current_wave = wave.open(filepath, 'wb')
        self.current_wave.setnchannels(self.channels)
        self.current_wave.setsampwidth(2)  # 16-bit
        self.current_wave.setframerate(self.sample_rate)

        # Start recording
        self.is_recording = True
        self.stream = sd.InputStream(
            callback=self.audio_callback,
            channels=self.channels,
            samplerate=self.sample_rate
        )
        self.stream.start()

        # Start worker thread
        self.recording_thread = threading.Thread(target=self.recording_worker, daemon=True)
        self.recording_thread.start()

        # Update UI
        self.status_label.config(text="Status: Recording", foreground="red")
        self.file_label.config(text=f"File: {filename}")
        self.start_btn.config(state=tk.DISABLED)
        self.stop_btn.config(state=tk.NORMAL)

        # Update tray icon
        self.tray_icon.icon = self.icon_active

        print(f"Recording started: {filepath}")

    def stop_recording(self):
        """Stop audio recording"""
        if not self.is_recording:
            return

        # Stop recording
        self.is_recording = False
        self.stream.stop()
        self.stream.close()

        # Wait for worker thread
        if self.recording_thread:
            self.recording_thread.join(timeout=1.0)

        # Close WAV file
        if self.current_wave:
            self.current_wave.close()
            self.current_wave = None

        # Update UI
        self.status_label.config(text="Status: Stopped", foreground="black")
        self.start_btn.config(state=tk.NORMAL)
        self.stop_btn.config(state=tk.DISABLED)

        # Update tray icon
        self.tray_icon.icon = self.icon_inactive

        print(f"Recording stopped: {self.current_file}")

    def start_recording_from_tray(self):
        """Start recording from tray menu"""
        self.root.after(0, self.start_recording)

    def stop_recording_from_tray(self):
        """Stop recording from tray menu"""
        self.root.after(0, self.stop_recording)

    def show_window(self):
        """Show the main window"""
        self.root.after(0, self._show_window)

    def _show_window(self):
        """Internal method to show window (thread-safe)"""
        self.root.deiconify()
        self.root.lift()
        self.root.focus_force()

    def hide_window(self):
        """Hide the main window to tray"""
        self.root.withdraw()

    def quit_app(self):
        """Quit the application"""
        self.stop_recording()
        self.tray_icon.stop()
        self.root.quit()

    def run(self):
        """Run the application"""
        self.root.mainloop()

if __name__ == "__main__":
    app = AudioRecorder()
    app.run()
