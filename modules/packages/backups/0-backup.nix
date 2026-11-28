{ ... }:

{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:

    let
      hosts = {
        "201" = "firefly";
        "202" = "nextcloud";
        # "203" = "home-assistant";
        "204" = "wiki-js";
        # "209" = "minecraft";
      };

      hostsFile = builtins.toFile "hosts.json" (builtins.toJSON hosts);
    in
    {
      packages.backup = pkgs.writeShellApplication {
        name = "backup";
        runtimeEnv.HOSTS_FILE = "${hostsFile}";
        runtimeInputs = with pkgs; [ jq ];

        text = builtins.readFile ./backupScript.sh;
      };

      packages.import = pkgs.writeShellApplication {
        name = "import";
        runtimeEnv.HOSTS_FILE = "${hostsFile}";
        runtimeInputs = with pkgs; [ jq ];

        text = builtins.readFile ./importScript.sh;
      };
    };
}
