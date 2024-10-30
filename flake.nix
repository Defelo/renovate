{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    inherit (nixpkgs) lib;

    eachDefaultSystem = lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
    ];
  in {
    packages = eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};

      format = pkgs.formats.json {};
      config = {
        autodiscover = true;
        onboardingNoDeps = "enabled";
        onboardingConfig = {
          extends = ["config:recommended"];
        };
        allowedPostUpgradeCommands = [
          "^nix run.*$"
        ];

        extends = ["config:recommended"];

        addLabels = ["renovate"];

        rangeStrategy = "bump";

        nix = {
          enabled = true;
        };

        lockFileMaintenance = {
          enabled = true;
          schedule = ["* 0 * * 1,4"];
        };

        semanticCommits = "enabled";

        platformCommit = "enabled";
        platformAutomerge = true;
        automergeStrategy = "squash";
      };
    in {
      default = pkgs.writeShellScriptBin "renovate" ''
        export RENOVATE_CONFIG_FILE=${format.generate "renovate-config.json" config}
        ${lib.getExe pkgs.renovate}
      '';
    });
  };
}
