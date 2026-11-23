{ self, ... }:

{
  flake.modules.nixos.configuration =
    {
      modulesPath,
      pkgs,
      ...
    }:

    {
      _module.args.domainName = "dodekaeder.name";

      imports = with self.modules.nixos; [
        (modulesPath + "/virtualisation/proxmox-lxc.nix")

        access
        network
        sops
      ];

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        sandbox = false;
        trusted-users = [
          "root"
          "elias"
        ];
      };

      proxmoxLXC = {
        manageNetwork = false;
        privileged = false;
      };

      services.fstrim.enable = false;

      environment.systemPackages = with pkgs; [
        vim
        git
        colmena
      ];

      system.stateVersion = "26.05";
    };
}
