# See: https://github.com/NixOS/nixpkgs/blob/32e940c7c420600ef0d1ef396dc63b04ee9cad37/pkgs/applications/misc/kratos/default.nix
{
  fetchFromGitHub,
  buildGoModule,
}: let
  pname = "hydra";
  # We need graceful refresh token revocation feature
  # It has not been released yet, so we build from master
  revision = "3a09db2";
  version = "3a09db2";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "ory";
      repo = "hydra";
      rev = "${revision}";
      hash = "sha256-3IYh7mo3bVWVSDRy1+fgSSa7qZqzb1apEXC4xm+7SP4=";
    };

    vendorHash = "sha256-qYloklVOnJQsuadA570JEfhHSwtnGXao40t51RS/m2o=";

    # Specify subpackages explicitly
    subPackages = [
      "."
    ];

    # Pass versioning information via ldflags
    ldflags = [
      "-X github.com/ory/hydra/v2/driver/config.Version=${version}"
    ];
  }
