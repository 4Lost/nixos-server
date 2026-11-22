{ ... }:

{
  flake.modules.nixos.nextcloud-theme =
    { config, ... }:

    {
      systemd.services.nextcloud-custom-config = {
        path = [
          config.services.nextcloud.occ
        ];
        script = ''
          nextcloud-occ theming:config name "Dodekaeder Cloud"
          nextcloud-occ theming:config url "https://www.dodekaeder.name";
          nextcloud-occ theming:config slogan "A frosty home for your data.";
          nextcloud-occ theming:config primary_color "#4A2029";
          nextcloud-occ theming:config background ${./background.png}
          nextcloud-occ theming:config logo ${./logo.png}
          nextcloud-occ theming:config favicon ${./favicon.png}
          nextcloud-occ config:system:delete integrity.check.disabled
        '';
        after = [ "nextcloud-setup.service" ];
        wantedBy = [ "multi-user.target" ];
      };
    };
}
