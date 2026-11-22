{ ... }:

{
  flake.modules.nixos.nextcloud-php =
    { lib, ... }:

    {
      services.nextcloud = {
        phpOptions = {
          "upload_max_filesize" = lib.mkForce "16G";
          "post_max_size" = lib.mkForce "16G";
          "memory_limit" = lib.mkForce "1G";
          "max_execution_time" = 3600;
          "max_input_time" = 3600;
          "opcache.interned_strings_buffer" = 16;
          "opcache.memory_consumption" = 256;
          "opcache.max_accelerated_files" = 20000;
        };

        phpExtraExtensions = all: [
          all.pdo_pgsql
        ];
      };
    };
}
