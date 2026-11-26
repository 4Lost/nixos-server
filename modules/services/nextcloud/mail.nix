{ ... }:

{
  flake.modules.nixos.nextcloud-mail =
    { config, ... }:

    {
      services.nextcloud.extraOptions = {
        mail_smtpmode = "sendmail";
        mail_sendmailmode = "pipe";
      };

      sops.secrets."mail-pwd" = {
        owner = "root";
        mode = "0400";
      };

      programs.msmtp = {
        enable = true;
        setSendmail = true;

        accounts.default = {
          host = "mail.ecloud.global";
          port = 587;

          tls = true;
          tls_starttls = true;
          auth = true;

          user = "dodekaeder@murena.io";
          from = "dodekaeder@murena.io";

          passwordeval = "cat ${config.sops.secrets."mail-pwd".path}";
        };
      };
    };
}
