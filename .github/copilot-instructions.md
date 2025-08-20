# whisper-input

whisper-input is a Python application that transcribes voice to text using OpenAI Whisper. It records audio from your microphone, transcribes it using AI, and types the result into the currently focused text field. The application is packaged using NIX flakes for dependency management and cross-platform distribution.

**ALWAYS follow these instructions first** and only fallback to additional search and context gathering if the information in the instructions is incomplete or found to be in error.

## Working Effectively

### Primary Method: NIX Flakes (Recommended)
- Install NIX package manager (if not already installed):
  ```bash
  # Verify NIX availability first
  nix --version || {
    # Install NIX if not available
    curl -L https://nixos.org/nix/install | sh
    source ~/.nix-profile/etc/profile.d/nix.sh
  }
  ```
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

5. **Connectivity and Version Checks**:
   - Check latest Whisper version: `curl -s https://api.github.com/repos/openai/whisper/releases/latest | grep '"tag_name"'`
   - Verify repository access: `curl -s https://api.github.com/repos/quoteme/whisper-input | grep '"clone_url"'`
   - Test NIX repository: `curl -s --connect-timeout 5 https://nixos.org/ > /dev/null && echo "NIX repos available"`

### Development Workflow
- Make changes to `src/whisper-input.py`
- Test in development shell: `nix develop` then `python3 src/whisper-input.py`
- For package changes: Edit `flake.nix` dependencies list
- Rebuild: `nix build` -- NEVER CANCEL: Takes 3-5 minutes
- Always test both CLI arguments and actual voice recording before committing

### Making Code Changes
When modifying the application:
1. **Edit Core Logic**: Main functions are in `src/whisper-input.py`:
   - `record_speech()`: Audio recording with silence detection  
   - `transcribe_speech()`: OpenAI Whisper integration
   - `type_text()`: Keyboard simulation output
   - `play_beep()`: Audio feedback

2. **Test Changes**: Always run validation commands first:
   ```bash
   # Quick syntax check
   python3 -m py_compile src/whisper-input.py
   
   # Test argument parsing  
   cd src && python3 whisper-input.py --help
   ```

3. **Full Testing**: Use development environment:
   ```bash
   nix develop  # NEVER CANCEL: Takes 1-2 minutes
   cd src && python3 whisper-input.py --silence_duration 2 --beep
   ```

4. **Dependency Changes**: If modifying `flake.nix`:
   - Edit the Python packages list (lines 17-41)
   - Test: `nix flake check` -- Takes 30-60 seconds
   - Rebuild: `nix build` -- NEVER CANCEL: Takes 3-5 minutes

### Repository Structure
```
.
├── .github/
│   └── copilot-instructions.md  # This instructions file
├── flake.nix                    # NIX package definition with Python dependencies
├── flake.lock                   # Locked dependency versions
├── readme.md                    # Basic usage instructions
└── src/
    ├── whisper-input.py         # Main application (93 lines)
    └── icons/                   # Notification icons
        ├── speaking.png         # "Start Speaking" notification
        ├── silence.png          # "Processing" notification
        └── thinking.png         # "Complete" notification
```

### Quick Validation Commands
Run these to verify repository state without full execution:
```bash
# Verify file structure
ls -la src/
wc -l src/whisper-input.py  # Should show 93 lines

# Test argument parsing (safe - no dependencies needed)
cd src && python3 -c "
import argparse
parser = argparse.ArgumentParser(description='Speech-to-Text with Silence Threshold')
parser.add_argument('--silence_duration', type=int, default=5)
parser.add_argument('--beep', action='store_true')
parser.print_help()
"
# Expected output:
# usage: -c [-h] [--silence_duration SILENCE_DURATION] [--beep]
# Speech-to-Text with Silence Threshold
# options:
#   -h, --help            show this help message and exit
#   --silence_duration SILENCE_DURATION
#   --beep

# Verify NIX flake structure
grep -A 2 -B 2 "whisper-input" flake.nix

# Test network connectivity to required services
curl -s --connect-timeout 5 --max-time 10 https://nixos.org/ > /dev/null && echo "✓ NIX repository accessible" || echo "✗ NIX repository not accessible"
curl -s --connect-timeout 5 --max-time 10 https://api.github.com/repos/openai/whisper/releases/latest > /dev/null && echo "✓ Whisper API accessible" || echo "✗ Whisper API not accessible"
curl -s --connect-timeout 5 --max-time 10 https://api.github.com/repos/quoteme/whisper-input > /dev/null && echo "✓ whisper-input repository accessible" || echo "✗ whisper-input repository not accessible"
```

### Dependency and Version Management
With network access to required APIs, you can now check versions and dependencies:

```bash
# Check latest OpenAI Whisper release
curl -s https://api.github.com/repos/openai/whisper/releases/latest | \
  python3 -c "import sys, json; print('Latest Whisper:', json.load(sys.stdin)['tag_name'])"

# Check repository status and latest commit
curl -s https://api.github.com/repos/quoteme/whisper-input | \
  python3 -c "import sys, json; r=json.load(sys.stdin); print(f'Repository: {r[\"full_name\"]}'); print(f'Default branch: {r[\"default_branch\"]}'); print(f'Last updated: {r[\"updated_at\"]}')"

# Verify NIX installation source integrity
curl -s -I https://nixos.org/nix/install | grep -E "HTTP|content-length"
```

These commands help validate that all required external dependencies are accessible and up-to-date before attempting builds or installations.

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
- Always use timeout values of 60+ minutes for builds and 20+ minutes for package installations

### Remote Repository Information
- Primary repository: `github:quoteme/whisper-input` (original)
- Current repository: `github:emailnjv/whisper-input` (fork)
- Use the `github:quoteme/whisper-input` reference for `nix run` commands
- Main branch: `master`
- No CI/CD workflows currently configured