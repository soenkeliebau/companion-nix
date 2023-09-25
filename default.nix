{ lib
, applyPatches
, stdenv
, fetchFromGitHub
, fetchYarnDeps
, prefetch-yarn-deps
, nodejs
, nodejs-slim
, matrix-sdk-crypto-nodejs
, nixosTests
, nix-update-script
}:

let
    pname = "companion";
    version = "v3.0.1";
    version_string = "v3.0.1+6068-stable-a05a9c89";

    src = applyPatches {
        src = fetchFromGitHub {
            owner = "bitfocus";
            repo = "companion";
            rev = version;
            hash = "sha256-x1C0sVpvqUhKLTa0bxuueK6PbVdxYysSpVimcPPGsro=";
        };
        patches = [ ./remove_vendored_respawn.patch ./fixed_version_string.patch ];
    };

    yarnOfflineCache = fetchYarnDeps {
        yarnLock = "${src}/yarn.lock";
        hash = "sha256-KWUlyiz2+mu6ve567KUfsnHis2m4FgpqjX80lt+ress=";
    };

in
stdenv.mkDerivation rec {
    inherit pname version src yarnOfflineCache;

    nativeBuildInputs = [
        prefetch-yarn-deps
        nodejs-slim
        nodejs.pkgs.yarn
        nodejs.pkgs.node-gyp-build
    ];

    configurePhase = ''
        runHook preConfigure

        export HOME=$(mktemp -d)
        export VERSION_STRING=""
        yarn config --offline set yarn-offline-mirror "$yarnOfflineCache"
        fixup-yarn-lock yarn.lock
        yarn install --frozen-lockfile --offline --no-progress --non-interactive --ignore-scripts
        patchShebangs node_modules/ bin/

        runHook postConfigure
    '';

    buildPhase = ''
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
