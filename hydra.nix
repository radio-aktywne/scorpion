# See: https://github.com/NixOS/nixpkgs/blob/32e940c7c420600ef0d1ef396dc63b04ee9cad37/pkgs/applications/misc/kratos/default.nix
{
  fetchFromGitHub,
  buildGoModule,
}: let
  pname = "hydra";
  version = "2.2.0";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "ory";
      repo = "hydra";
      rev = "v${version}";
      hash = "sha256-WzkS97paI49yieHiNpOce4XrZ/2GdPA1mbrfgExVcyo=";
    };

    vendorHash = "sha256-c8gMlY2QcB6V0MJ9ne44MYvnPeqz/zG+8UZeloVZKDc=";

    # Specify subpackages explicitly
    subPackages = [
      "."
    ];

    # Pass versioning information via ldflags
    ldflags = [
      "-X github.com/ory/hydra/v2/driver/config.Version=${version}"
    ];
  }
