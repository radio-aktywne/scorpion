# See: https://github.com/NixOS/nixpkgs/blob/32e940c7c420600ef0d1ef396dc63b04ee9cad37/pkgs/applications/misc/kratos/default.nix
{
  fetchFromGitHub,
  buildGoModule,
}: let
  pname = "hydra";
  revision = "v2.3.0";
  version = "2.3.0";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "ory";
      repo = "hydra";
      rev = "${revision}";
      hash = "sha256-f/pBRrFMfpcYSfejIGpCD5Kywtg5oyovw5RemvRDPTs=";
    };

    vendorHash = "sha256-g2NDPwLgM/LmndCgh5pXjc1DJ3pnGcHlWm+opPVK1bE=";

    # Specify subpackages explicitly
    subPackages = [
      "."
    ];

    # Pass versioning information via ldflags
    ldflags = [
      "-X github.com/ory/hydra/v2/driver/config.Version=${version}"
    ];
  }
