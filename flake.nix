{
  description = "Voice-to-text transcription tool using OpenAI Whisper";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        myPython =
          (pkgs.python312.withPackages
            (ps: with ps; [
              openai-whisper
              pyaudio
              playsound
              pynput
              dbus-python
              # pydbus
              plyer
              termcolor
              (
                buildPythonPackage
                  rec {
                    pname = "beepy";
                    version = "1.0.7";
                    src = fetchPypi {
                      inherit pname version;
                      sha256 = "sha256-gXNI/zzAmKyo0d57wVKSt2L94g/MCgIPzOp5NpQNW18=";
                    };
                    doCheck = false;
                    propagatedBuildInputs = [
                      ps.simpleaudio
                    ];
                  }
              )
            ]));
        dependencies = [
          myPython
        ];
      in
      rec {
        defaultApp = apps.whisper-input;

        apps.whisper-input = {
          type = "app";
          program = "${packages.whisper-input}/bin/whisper-input";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ dependencies ];
        };

        defaultPackage = packages.whisper-input;
        
        packages.whisper-input = pkgs.stdenv.mkDerivation {
          pname = "whisper-input";
          version = "1.0.0";
          buildInputs = dependencies;
          src = ./src;
          dontBuild = true;
          installPhase = ''
            mkdir -p $out/bin $out/share/whisper-input
            cp -r . $out/share/whisper-input/
            # Create the executable script
            cat > $out/bin/whisper-input << EOF
            #!${pkgs.stdenv.shell}
            exec ${myPython}/bin/python3 $out/share/whisper-input/whisper-input.py "\$@"
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
        };
      }
    );
}






