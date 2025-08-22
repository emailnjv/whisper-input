{
  description = "Voice-to-text transcription tool using OpenAI Whisper";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
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
          (pkgs.python311.withPackages
            (ps: with ps; [
              openai-whisper
              pyaudio
              playsound
              pynput
              dbus-python
              # pydbus
              plyer
              termcolor
              numba
              (
                buildPythonPackage
                  rec {
                    pname = "beepy";
                    version = "1.0.9";
                    src = fetchPypi {
                      inherit pname version;
                      sha256 = "sha256-BbLWeJq7Q5MAaeHZalbJ6LBJg3jgl4TP6aHewCNo/Ks=";
                    };
                    doCheck = false;
                    postPatch = ''
                      substituteInPlace setup.py \
                        --replace-fail "long_description=readme()," "long_description=\"\","
                    '';
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






