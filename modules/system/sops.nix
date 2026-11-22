{ inputs, self, ... }:

{
  flake.modules.nixos.sops =
    { pkgs, ... }:

    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      environment.systemPackages = with pkgs; [
        age
        sops
      ];

      sops = {
        defaultSopsFile = (self + /secrets/secrets.yaml);
        defaultSopsFormat = "yaml";
        age.keyFile = "/etc/sops/key.txt";
        secrets."user_password".neededForUsers = true;
      };
    };
}
