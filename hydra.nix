# See: https://github.com/NixOS/nixpkgs/blob/40ee5e1944bebdd128f9fbada44faefddfde29bd/pkgs/by-name/kr/kratos/package.nix
{
  fetchFromGitHub,
  buildGoModule,
}: let
  pname = "hydra";
  version = "2.3.0";
in
  buildGoModule {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "ory";
      repo = "hydra";
      rev = "v${version}";
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
