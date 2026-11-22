{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  packages = [
    pkgs.sops
    pkgs.age
    pkgs.openssh
  ];

  shellHook = ''
    if ! ssh-add -l >/dev/null 2>&1; then
      ssh-add "$HOME/.ssh/id_rsa"
    fi
  '';
}
