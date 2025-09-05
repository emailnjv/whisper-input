{ pkgs ? import <nixpkgs> {} }:

let
  myPython = pkgs.python311.withPackages (ps: with ps; [
    openai-whisper
    pyaudio
    playsound
    pynput
    dbus-python
    plyer
    termcolor
    numba
    (ps.buildPythonPackage rec {
      pname = "beepy";
      version = "1.0.9";
      pyproject = true;
      build-system = [ ps.setuptools ];
      src = ps.fetchPypi {
        inherit pname version;
        sha256 = "sha256-BbLWeJq7Q5MAaeHZalbJ6LBJg3jgl4TP6aHewCNo/Ks=";
      };
      doCheck = false;
      postPatch = ''
        substituteInPlace setup.py \
          --replace-fail "long_description=readme()," "long_description=\"\","
      '';
      propagatedBuildInputs = [ ps.simpleaudio ];
    })
  ]);
in
pkgs.stdenv.mkDerivation {
  pname = "whisper-input";
  version = "1.0.2";
  buildInputs = [ myPython ];
  src = ./src;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin $out/share/whisper-input
    cp -r . $out/share/whisper-input/
    # Create the executable script
    cat > $out/bin/whisper-input << EOF
    #!${pkgs.stdenv.shell}
    exec ${myPython}/bin/python3 $out/share/whisper-input/whisper-input.py --silence_duration 2"\$@"
    EOF
    chmod +x $out/bin/whisper-input
  '';
  
  meta = with pkgs.lib; {
    description = "Voice-to-text transcription tool using OpenAI Whisper";
    homepage = "https://github.com/emailnjv/whisper-input";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}