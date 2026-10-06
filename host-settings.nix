{
  config,
  host,
  modulesPath,
  pkgs,
  ...
}:

{
  imports =
    let
      commit = "5efb5a6f4f5ab192817d28557dd4d650fa14d866";
    in
    [
      "${
        builtins.fetchTarball {
          url = "https://github.com/Mic92/sops-nix/archive/${commit}.tar.gz";
          sha256 = "sha256-0qmskz73girklipfmxwp7w4fmnl6pfjwjdqymvrpqnri0rw";
        }
      }/modules/sops"
      (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ];

  networking = {
    useDHCP = false;
    enableIPv6 = false;

    interfaces.eth0.ipv4.addresses = [
      {
        address = host.ip;
        prefixLength = 24;
      }
    ];

    firewall.allowedTCPPorts = host.firewall;
    defaultGateway = "192.168.3.1";
    nameservers = [ "1.1.1.1" ];
  };

  nix.settings.sandbox = false;

  proxmoxLXC = {
    manageNetwork = true;
    privileged = false;
  };

  services.fstrim.enable = false; # Let Proxmox host handle fstrim

  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.elias = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];

    users.users.elias.openssh.authorizedKeys.keyFiles = [
      config.sops.secrets.ssh_keys.path
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  system.stateVersion = "26.05";
}
