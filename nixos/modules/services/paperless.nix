{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.hostConfig.services.paperless;
in {
  options.hostConfig.services.paperless = {
    enable = mkEnableOption "Paperless service";
  };

  config = mkIf cfg.enable {
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
      passwordFile = "/run/secrets/paperless-password";
      extraConfig = {
        PAPERLESS_OCR_LANGUAGE = "por+eng+spa";
        PAPERLESS_OCR_LANGUAGES = "por";
        PAPERLESS_FILENAME_FORMAT = "{correspondent}/{document_type}/{created}-{title}-{tag_list}-{asn}";
      };
    };

    users.users.andre.extraGroups = [config.services.paperless.user];

    sops.secrets.paperless-password = {
      key = "password";
      format = "yaml";
      owner = config.services.paperless.user;
      sopsFile = ../../../secrets/paperless.yaml;
    };
  };
}