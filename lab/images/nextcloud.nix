# The Nextcloud container is running with Apache and PHP-FPM.
# Apache is used because Nextcloud uses an .htaccess file.
{ pkgs, ... }:
let
  nextcloud = pkgs.nextcloud34;
  php = pkgs.php85;

  apacheConfig = pkgs.writeText "httpd.conf" (
    with pkgs;
    ''
      ServerName 0.0.0.0
      ServerRoot /var/lib/httpd
      Listen 8080

      User httpd
      Group httpd

      SetEnv NEXTCLOUD_CONFIG_DIR /var/nextcloud/config

      LoadModule authn_core_module ${apacheHttpd}/modules/mod_authn_core.so
      LoadModule authz_core_module ${apacheHttpd}/modules/mod_authz_core.so
      LoadModule dir_module ${apacheHttpd}/modules/mod_dir.so
      LoadModule env_module ${apacheHttpd}/modules/mod_env.so
      LoadModule log_config_module ${apacheHttpd}/modules/mod_log_config.so
      LoadModule mime_module ${apacheHttpd}/modules/mod_mime.so
      LoadModule mpm_event_module ${apacheHttpd}/modules/mod_mpm_event.so
      LoadModule unixd_module ${apacheHttpd}/modules/mod_unixd.so
      LoadModule proxy_module ${apacheHttpd}/modules/mod_proxy.so
      LoadModule proxy_fcgi_module ${apacheHttpd}/modules/mod_proxy_fcgi.so

      <FilesMatch \.php$>
          SetHandler "proxy:unix:/var/run/php-fpm.sock|fcgi://localhost/"
      </FilesMatch>

      <Directory "${nextcloud}">
          Options Indexes FollowSymLinks
          AllowOverride All
          Require all granted
      </Directory>
      DocumentRoot "${nextcloud}"

      ErrorLog "/dev/stderr"
      TransferLog "/dev/stdout"
      TypesConfig ${pkgs.apacheHttpd}/conf/mime.types
    ''
  );

  nextcloudConfig = import ./nextcloud/config.php.nix { inherit nextcloud; };

  phpFpmConfig = pkgs.writeText "php-fpm.conf" ''
    [global]
    error_log = /dev/stderr
    include = ${phpPoolConfig}
  '';

  phpPoolConfig = pkgs.writeText "www.conf" ''
    [www]
    user = httpd
    group = httpd

    listen = /var/run/php-fpm.sock

    listen.owner = httpd
    listen.group = httpd
    listen.mode = 0660

    pm = ondemand

    pm.max_children = 5

    pm.process_idle_timeout = 10s

    catch_workers_output = yes
    decorate_workers_output = no

    php_admin_value[short_open_tag] = On
  '';

  entryPointScript = pkgs.writers.writeBashBin "entrypoint" ''
    set -ex
    trap "kill 0" EXIT

    # Write the secrets into config.php
    sed -i "s/POSTGRES_PASSWORD/$POSTGRES_PASSWORD/g" /var/nextcloud/config/config.php
    sed -i "s/POSTGRES_HOST/$NEXTCLOUD_DB_RW_SERVICE_HOST/g" /var/nextcloud/config/config.php
    sed -i "s/PASSWORD_ENCRYPTION_KEY/$PASSWORD_ENCRYPTION_KEY/g" /var/nextcloud/config/config.php
    sed -i "s/PASSWORD_SALT/$PASSWORD_SALT/g" /var/nextcloud/config/config.php

    ${php}/bin/php-fpm -F -O --fpm-config ${phpFpmConfig} &
    ${pkgs.apacheHttpd}/bin/httpd -D FOREGROUND -f ${apacheConfig} &
    wait -n
  '';
in
pkgs.dockerTools.buildImage {
  name = "nextcloud";

  runAsRoot = with pkgs; ''
    ${dockerTools.shadowSetup}
    groupadd -r httpd
    useradd -r httpd -g httpd
    mkdir -p /var/lib/httpd/logs
    chown -R httpd:httpd /var/lib/httpd

    # FIXME: The data and apps dir need to be hosted on a NAS
    mkdir -p /var/run
    mkdir -p /var/nextcloud/apps
    mkdir -p /var/nextcloud/config
    mkdir -p /var/nextcloud/data
    chown -R httpd:httpd /var/nextcloud
    chmod -R 0750 /var/nextcloud/
    chmod 0640 /var/nextcloud/config/config.php
  '';

  contents = with pkgs; [
    bash
    coreutils
    gnused
    ps
    vim

    (writeTextDir "var/nextcloud/config/config.php" (nextcloudConfig))
  ];

  config = {
    Cmd = [ "${entryPointScript}/bin/entrypoint" ];
    Env = [
      "NEXTCLOUD_CONFIG_DIR=/var/nextcloud/config"
    ];
    ExposedPorts = {
      "8080/tcp" = { };
    };
  };
}
