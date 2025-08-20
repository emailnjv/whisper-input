# whisper-input

whisper-input is a Python application that transcribes voice to text using OpenAI Whisper. It records audio from your microphone, transcribes it using AI, and types the result into the currently focused text field. The application is packaged using NIX flakes for dependency management and cross-platform distribution.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Primary Method: NIX Flakes (Recommended)
- Install NIX package manager:
  - `curl -L https://nixos.org/nix/install | sh`
  - `source ~/.nix-profile/etc/profile.d/nix.sh`
- Run the application directly:
  - `nix run github:quoteme/whisper-input` -- NEVER CANCEL: First run takes 5-10 minutes for dependency download and Whisper model download (~150MB). Set timeout to 15+ minutes.
- Build locally for development:
  - `nix build` -- NEVER CANCEL: Takes 3-5 minutes for dependencies. Set timeout to 10+ minutes.
  - `./result/bin/whisper-input`
- Enter development shell:
  - `nix develop` -- Takes 1-2 minutes. Set timeout to 5+ minutes.

### Alternative Method: Python pip (Fallback)
Use this method only if NIX is not available or fails:
- Install system dependencies:
  - Ubuntu/Debian: `sudo apt-get install portaudio19-dev python3-dev build-essential`
  - macOS: `brew install portaudio`
  - Windows: Install Visual Studio Build Tools
- Install Python dependencies:
  - `pip3 install openai-whisper pyaudio playsound pynput dbus-python plyer termcolor beepy simpleaudio` -- NEVER CANCEL: Takes 10-15 minutes, downloads ~150MB+ of data. Set timeout to 20+ minutes.
- Run the application:
  - `cd src && python3 whisper-input.py`

### System Requirements
- **Audio Input**: Microphone access required for recording
- **GUI Environment**: Desktop environment required for notifications and keyboard simulation
- **Network**: Internet connection required for initial Whisper model download
- **Storage**: ~200MB free space for Whisper models and dependencies

## Validation

### Critical Validation Steps
Always manually validate functionality after making changes:

1. **Basic Functionality Test**:
   - Run `nix run github:quoteme/whisper-input --silence_duration 2 --beep`
   - Verify you hear a beep sound (indicates audio output works)
   - Speak for 1-2 seconds then stay silent for 2+ seconds
   - Verify recording stops automatically after silence
   - Check that transcribed text appears in your currently focused text field

2. **Error Handling Test**:
   - Test with no microphone: Verify graceful error message
   - Test with no internet: Verify helpful error about model download
   - Test in non-GUI environment: Verify appropriate warnings

3. **Development Validation**:
   - Always test changes using `nix develop` shell first
   - Run `python3 src/whisper-input.py --help` to verify argument parsing
   - Test both with and without `--beep` flag

### Environment-Specific Testing
- **Headless Environment**: Application will fail gracefully - notifications and keyboard simulation require GUI
- **No Audio**: Application will show clear error about missing audio input device
- **Network Issues**: First run may fail downloading Whisper models - retry when network is stable

## Common Tasks

### Application Arguments
```bash
# Default behavior (5 second silence threshold)
nix run github:quoteme/whisper-input

# Custom silence duration with beep sounds
nix run github:quoteme/whisper-input -- --silence_duration 3 --beep

# Get help
nix run github:quoteme/whisper-input -- --help
```

### Timing Expectations
- **First Run**: 5-10 minutes (NIX dependencies + Whisper model download)
- **Subsequent Runs**: 10-30 seconds (model loading time)
- **Recording**: User-controlled (stops after silence_duration seconds of silence)
- **Transcription**: 2-10 seconds for typical voice clips (depends on audio length)
- **Total Workflow**: 30-60 seconds for typical usage after initial setup

### Troubleshooting Common Issues

1. **"No module named 'whisper'" Error**:
   - Use NIX method: `nix run github:quoteme/whisper-input`
   - If using pip: Install dependencies first

2. **Audio Input Errors**:
   - Check microphone permissions
   - Test with: `arecord -l` (Linux) or system audio settings
   - Ensure no other applications are using microphone

3. **Network/Download Errors**:
   - Whisper models download on first use - requires stable internet
   - Check firewall settings for outbound HTTPS
   - Clear cache if corrupted: `~/.cache/whisper/` (Linux/macOS)

4. **Build Failures**:
   - NIX builds require internet access
   - On older systems, try: `nix --experimental-features 'nix-command flakes' run github:quoteme/whisper-input`

### Development Workflow
- Make changes to `src/whisper-input.py`
- Test in development shell: `nix develop` then `python3 src/whisper-input.py`
- For package changes: Edit `flake.nix` dependencies list
- Rebuild: `nix build` -- NEVER CANCEL: Takes 3-5 minutes
- Always test both CLI arguments and actual voice recording before committing

### Repository Structure
```
.
├── flake.nix              # NIX package definition with Python dependencies
├── flake.lock            # Locked dependency versions
├── readme.md             # Basic usage instructions
└── src/
    ├── whisper-input.py  # Main application (93 lines)
    └── icons/            # Notification icons
        ├── speaking.png  # "Start Speaking" notification
        ├── silence.png   # "Processing" notification
        └── thinking.png  # "Complete" notification
```

### Key Dependencies
- **openai-whisper**: AI transcription engine (~150MB models)
- **pyaudio**: Audio recording (requires system PortAudio library)
- **pynput**: Keyboard simulation for text typing
- **plyer**: Cross-platform notifications
- **termcolor**: Colored console output
- **beepy**: Audio feedback sounds

### Limitations
- Requires GUI environment (notifications and keyboard simulation)
- Requires microphone access
- First-time model download requires internet connection
- Transcription quality depends on audio quality and language (optimized for English)
- Cannot run in completely headless environments

### Performance Notes
- NEVER CANCEL long-running operations - model downloads and dependency builds are normal
- Whisper "base" model provides good balance of speed vs accuracy
- Recording stops automatically based on silence detection
- Application uses temporary files in system temp directory