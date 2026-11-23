{ ... }:

{
  flake.modules.nixos.nextcloud-user =
    { config, ... }:

    {
      sops.secrets."nixos/nextcloud/elias-pwd" = {
        owner = "nextcloud";
        group = "nextcloud";
        mode = "0400";
      };

      services.nextcloud.ensureUsers = {
        elias = {
          email = "elias.schroeter@e.email";
          passwordFile = config.sops.secrets."nixos/nextcloud/elias-pwd".path;
        };
      };

      systemd.services.nextcloud-make-elias-admin = {
        description = "Make Elias a Nextcloud administrator";
        after = [ "nextcloud-setup.service" ];
        requires = [
          "nextcloud-setup.service"
          "nextcloud-ensure-users.service"
        ];
        wantedBy = [ "multi-user.target" ];

        path = [
          config.services.nextcloud.occ
        ];

        script = ''
          nextcloud-occ group:adduser admin elias || true
        '';
      };
    };
}
