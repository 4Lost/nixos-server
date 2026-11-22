{ ... }:

{
  flake.modules.nixos.nextcloud-apps =
    { config, pkgs, ... }:

    {
      services.nextcloud = {
        extraApps = {
          inherit (config.services.nextcloud.package.packages.apps)
            calendar
            contacts
            cospend
            notes
            onlyoffice
            ;
        };
        imaginary.enable = true;
        settings.preview_format = "webp";
      };

      services.onlyoffice = {
        enable = true;
        hostname = "localhost";
        securityNonceFile = "${pkgs.writeText "nixos-test-onlyoffice-nonce.conf" ''
          set $secure_link_secret "nixostest";
        ''}";
      };

      services.epmd.listenStream = "0.0.0.0:4369";

      systemd.services.nextcloud-disable-dashboard = {
        description = "Disable Dashboard app";
        after = [ "nextcloud-setup.service" ];
        requires = [ "nextcloud-setup.service" ];

        path = [
          config.services.nextcloud.occ
        ];

        script = ''
          nextcloud-occ app:disable dashboard || true
        '';
      };
    };
}
