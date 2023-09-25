{ lib
, git
, applyPatches
, mkYarnPackage
, fetchYarnDeps
, fetchFromGitHub
}:

mkYarnPackage rec {
    pname = "companion";
    version = "v3.0.1";

    src = applyPatches {
        src = fetchFromGitHub {
            owner = "bitfocus";
            repo = "companion";
            rev = version;
            hash = "sha256-x1C0sVpvqUhKLTa0bxuueK6PbVdxYysSpVimcPPGsro=";
        };
        patches = [ ./remove_vendored_respawn.patch ];
    };

    packageJSON = "${src}/package.json";
    offlineCache = fetchYarnDeps {
        yarnLock = "${src}/yarn.lock";
        hash = "sha256-KWUlyiz2+mu6ve567KUfsnHis2m4FgpqjX80lt+ress=";
    };

    extraBuildInputs = [ git ];

    buildPhase = ''
        export HOME=$(mktemp -d)
        runHook preBuild

        yarn --offline build:writefile
        yarn --offline dist

        runHook postBuild
    '';

    meta = {
        changelog = "https://github.com/bitfocus/companion/blob/${src.rev}/CHANGELOG.md";
        description = "Bitfocus Companion - Open Source Controller for Elgato Streamdeck";
        homepage = "https://bitfocus.io/companion";
        license = lib.licenses.mit;
        mainProgram = "companion";
    };
}
