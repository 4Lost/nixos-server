{
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    ./services/firefly.nix
  ];

  nix.settings.sandbox = false;

  proxmoxLXC = {
    manageNetwork = true;
    privileged = false;
  };

  networking = {
    useDHCP = false;

    defaultGateway = "192.168.3.1";
    nameservers = [ "1.1.1.1" ];

    enableIPv6 = false;
  }

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

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCTbgre6iWZWDtUJFgVPdzUvs1yTE1IkncPWgXz/5AQGT5ymlTxKQ7dqgjsjuioAM3ok1/Jg8oKX+5HPR3HGdrCwGi6iTVx8I6ojGZXPcqbus8G7UWIDwRJhH/Cx/qNkSFRdd1CK7BEUMTl1Ehgyl9kTbRgr2q1LaX/60qYUUfLi+h1YaC1jkNajN2d+tQnXUUBrauzd4LqDh9Lzh5GG1EARh0PAArzyL/URgFwUUu5RJapjo4yIKWaaG6Z2uUi2sQjtMbZRTYdWVdBHnzRnVJaS/Bc4nxIihtNcwJ/yeSEeRlpyXeX0UnsPK18Uif9jFdM6W4Ww90rinQjZkFIscFyRroflf11d1G4nTMLJIQU7LG0xqd6R50b68sX5qu9t8TI4j/E8PUqBFQ7YRI9y+tWZ36xgbqVcxyZt7IHI8UwzvC9PWxyMlzLBXCit95BQEwzMcQpgRe7BELPlOhnBErnaOXnXPUm5fWiNuNDSIP83VvaXBrTK4D8Fr/YMDxGlWIw3O0ZMwNMMDO4C56OraiWvNhPlxqtQfTkxbKaT613nPjgQWxoIeBK7ld4r8vqpY09Etao2vgP71twfHZMnc1rFK3oeAeWnd63SYOlMVJ3VfHjCo+BUl+rtitUfFfq54XDOxUDEnri7y0G7PwlyVzL9CEF/f3mRke7m21mxpT5/Q== elias.schroeter@e.email"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  system.stateVersion = "26.05";
}
