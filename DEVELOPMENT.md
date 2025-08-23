# Development Guide

This document provides detailed information for developers working on the whisper-input project.

## Project Structure

```
whisper-input/
├── flake.nix           # Nix flake configuration
├── flake.lock          # Locked dependency versions
├── readme.md           # Main project documentation
├── DEVELOPMENT.md      # This file
└── src/
    ├── whisper-input.py    # Main application
    └── icons/
        ├── speaking.png    # Icon for recording state
        ├── silence.png     # Icon for processing state
        └── thinking.png    # Icon for completion state
```

## Development Environment

### Using Nix (Recommended)

```bash
# Enter development shell with all dependencies
nix develop

# Run the application directly
python src/whisper-input.py --help

# Build and test the package
nix build

# Run the packaged version
./result/bin/whisper-input
```

### Manual Setup

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install openai-whisper pyaudio pynput plyer termcolor beepy

# Run application
python src/whisper-input.py
```

## Code Structure

### Main Application (`whisper-input.py`)

The application is structured as a simple pipeline with the following functions:

#### `play_beep(sound_type, beep_enabled)`
- Plays audio feedback using the beepy library
- Conditional based on user preference
- Uses different sound types for different events

#### `record_speech(silence_threshold=500, silence_duration=10, beep_enabled=True)`
- Captures audio input from the default microphone
- Implements real-time silence detection using RMS calculation
- Parameters:
  - `silence_threshold`: Audio level below which silence is detected (default: 500)
  - `silence_duration`: Seconds of silence before stopping (default: 10)
  - `beep_enabled`: Whether to play audio feedback

**Algorithm:**
1. Initialize PyAudio stream with 44.1kHz, 16-bit, mono configuration
2. Continuously read 1024-frame chunks
3. Calculate RMS (Root Mean Square) for volume detection
4. Track time since last sound above threshold
5. Stop recording when silence duration exceeded
6. Save accumulated frames to temporary WAV file

#### `transcribe_speech(file_path, beep_enabled=True)`
- Loads OpenAI Whisper model ("base" by default)
- Processes the recorded audio file
- Returns transcribed text string

#### `type_text(text)`
- Uses pynput to simulate keyboard input
- Types the transcribed text into the currently focused application

### Configuration

The application uses argparse for command-line configuration:

```python
parser.add_argument("--silence_duration", type=int, default=5)
parser.add_argument("--beep", action='store_true')
```

## Dependency Management

### Nix Dependencies

The flake.nix defines a Python environment with the following packages:

```nix
myPython = pkgs.python312.withPackages (ps: with ps; [
  openai-whisper     # Speech recognition
  pyaudio           # Audio I/O
  playsound         # (Currently unused)
  pynput            # Keyboard simulation
  dbus-python       # System integration
  plyer             # Cross-platform notifications
  termcolor         # Colored terminal output
  (buildPythonPackage {  # Custom beepy package
    pname = "beepy";
    version = "1.0.7";
    # ... package definition
  })
]);
```

### Custom Package: beepy

The beepy package is built from PyPI source due to potential unavailability in nixpkgs:

- **Purpose**: Provides simple audio feedback
- **Dependencies**: simpleaudio
- **Configuration**: `doCheck = false` to skip tests during build

## Testing Strategy

### Manual Testing

1. **Audio Input Test**
   ```bash
   python src/whisper-input.py --beep
   # Verify: Start beep plays, recording begins, notifications appear
   ```

2. **Silence Detection Test**
   ```bash
   python src/whisper-input.py --silence_duration 2
   # Verify: Recording stops after 2 seconds of silence
   ```

3. **Transcription Test**
   - Speak clearly: "Hello world test transcription"
   - Verify: Text appears in focused application

### Integration Testing

```bash
# Test with different applications
# 1. Text editor (gedit, notepad, etc.)
# 2. Web browser input fields
# 3. Terminal applications
```

## Performance Optimization

### Whisper Model Selection

Models available and their trade-offs:

| Model  | Size   | Speed     | Accuracy | Use Case |
|--------|--------|-----------|----------|----------|
| tiny   | 39 MB  | ~32x RT   | Basic    | Testing  |
| base   | 74 MB  | ~16x RT   | Good     | Default  |
| small  | 244 MB | ~6x RT    | Better   | Quality  |
| medium | 769 MB | ~2x RT    | High     | Accuracy |
| large  | 1550 MB| ~1x RT    | Best     | Maximum  |

*RT = Real Time (32x RT means 32 times faster than real-time audio)*

To change the model:
```python
model = whisper.load_model("small")  # Instead of "base"
```

### Memory Management

- Whisper models are loaded once per session
- Temporary audio files are automatically cleaned up
- PyAudio streams are properly closed after use

## Troubleshooting Development Issues

### PyAudio Installation Problems

```bash
# Linux: Install development headers
sudo apt-get install portaudio19-dev python3-dev

# macOS: Use Homebrew
brew install portaudio

# If still failing, use conda:
conda install pyaudio
```

### Whisper Model Loading Issues

```bash
# Clear Whisper cache
rm -rf ~/.cache/whisper

# Manually download models
python -c "import whisper; whisper.load_model('base')"
```

### Permission Issues

```bash
# Linux: Add user to audio group
sudo usermod -a -G audio $USER

# Check microphone permissions
arecord -l  # List available devices
```

## Code Style and Conventions

### Python Style
- Follow PEP 8 guidelines
- Use descriptive variable names
- Include type hints for public functions
- Add docstrings for complex functions

### Nix Style
- Use nixpkgs-fmt for formatting
- Follow nixpkgs conventions
- Include metadata for packages

## Contributing Workflow

1. **Fork and Clone**
   ```bash
   git clone https://github.com/yourusername/whisper-input
   cd whisper-input
   ```

2. **Development Setup**
   ```bash
   nix develop
   ```

3. **Make Changes**
   - Edit source code
   - Test changes manually
   - Update documentation if needed

4. **Test Build**
   ```bash
   nix build
   ./result/bin/whisper-input --help
   ```

5. **Submit PR**
   - Include description of changes
   - Test on multiple platforms if possible
   - Update documentation as needed

## Future Enhancements

### Potential Improvements

1. **Configuration File Support**
   - YAML/JSON configuration
   - User preferences persistence

2. **Advanced Audio Processing**
   - Noise reduction filters
   - Multiple microphone support
   - Audio quality detection

3. **Extended Whisper Integration**
   - Model selection via CLI
   - Language detection/specification
   - Custom model support

4. **UI Improvements**
   - System tray integration
   - Hotkey activation
   - Visual recording indicator

5. **Output Options**
   - Clipboard copying
   - File saving
   - Multiple output formats

### Architecture Considerations

- Plugin system for different input/output methods
- Async processing for better responsiveness
- Configuration validation and error handling
- Logging system for debugging

## Security Considerations

### Data Privacy
- All processing happens locally
- No network communication required
- Temporary files are cleaned up
- No persistent storage of audio/text

### System Security
- Requires microphone access
- Requires accessibility permissions for keyboard simulation
- Consider sandboxing for distribution

### Best Practices
- Validate all user inputs
- Handle file system errors gracefully
- Respect system audio permissions
- Clean up resources properly