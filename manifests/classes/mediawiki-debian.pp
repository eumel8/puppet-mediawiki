define mediawiki::new(
  $ensure=present,
  $targetdir='',
  $admin,
  $servername=$name,
  $serveralias=$name,
  $ip='*',
  $port=80) {

  include apache::common

  case $ensure {
    present: {
      include mediawiki::install

      file { 'wiki-{$name}':
        ensure  => directory,
        path    => "/var/lib/mediawiki/wikis/${name}",
        mode    => '0755',
        require => File['wikis'];
      }

      file {
        [ "/var/lib/mediawiki/wikis/${name}/upload",
          "/var/lib/mediawiki/wikis/${name}/images",
          "/var/lib/mediawiki/wikis/${name}/config"]:
            ensure  => directory,
            owner   => 'www-data',
            group   => 'www-data',
            require => File['wiki-{$name}'],
            notify  => File["/var/lib/mediawiki/wikis/${name}/config/index.php"],
            mode    => '0700';
          "/var/lib/mediawiki/wikis/${name}/extensions":
            ensure  => directory,
            require => File['wiki-{$name}'],
            mode    => '0755';
          "/var/lib/mediawiki/wikis/${name}/config/index.php":
            content => template('mediawiki/index.php.erb'),
            owner   => 'www-data',
            group   => 'www-data',
            mode    => '0700';
      }

      file {
        "/var/lib/mediawiki/wikis/${name}/api.php":
          ensure  => link,
          target  => '/usr/share/mediawiki/api.php',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/img_auth.php":
          ensure  => link,
          target  => '/usr/share/mediawiki/img_auth.php',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/includes":
          ensure  => link,
          target  => '/usr/share/mediawiki/includes',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/index.php":
          ensure  => link,
          target  => '/usr/share/mediawiki/index.php',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/install-utils.inc":
          ensure  => link,
          target  => '/usr/share/mediawiki/install-utils.inc',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/languages":
          ensure  => link,
          target  => '/usr/share/mediawiki/languages',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/maintenance":
          ensure  => link,
          target  => '/usr/share/mediawiki/maintenance',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/opensearch_desc.php":
          ensure  => link,
          target  => '/usr/share/mediawiki/opensearch_desc.php',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/profileinfo.php":
          ensure  => link,
          target  => '/usr/share/mediawiki/profileinfo.php',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/redirect.php":
          ensure  => link,
          target  => '/usr/share/mediawiki/redirect.php',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/redirect.phtml":
          ensure  => link,
          target  => '/usr/share/mediawiki/redirect.phtml',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/skins":
          ensure  => link,
          target  => '/usr/share/mediawiki/skins',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/StartProfiler.php":
          ensure  => link,
          target  => '/usr/share/mediawiki/StartProfiler.php',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/Test.php":
          ensure  => link,
          target  => '/usr/share/mediawiki/Test.php',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/thumb.php":
          ensure  => link,
          target  => '/usr/share/mediawiki/thumb.php',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/trackback.php":
          ensure  => link,
          target  => '/usr/share/mediawiki/trackback.php',
          require => File['wiki-{$name}'];
        "/var/lib/mediawiki/wikis/${name}/wiki.phtml":
          ensure  => link,
          target  => '/usr/share/mediawiki/wiki.phtml',
          require => File['wiki-{$name}'];
      }

      file {'apache-file':
        path    => "/etc/apache2/sites-available/${name}",
        content => template('mediawiki/wiki.erb'),
        notify  => Exec['enable-site'];
      }

      exec { 'enable-site':
        command => "/usr/sbin/a2ensite ${name}",
        onlyif  => "/bin/readlink -e /etc/apache2/sites-available/${name}",
        notify  => Exec['reload-apache2'];
      }

    }

    enabled: {
      exec { 'enable-site':
        command => "/usr/sbin/a2ensite ${name}",
        onlyif  => "/bin/readlink -e /etc/apache2/sites-available/${name}",
        notify  => Exec['reload-apache2'];
      }

    }

    disabled: {
      exec { 'disable-site':
        command => "/usr/sbin/a2dissite ${name}",
        onlyif  => "/bin/readlink -e /etc/apache2/sites-enabled/${name}",
        notify  => Exec['reload-apache2'];
      }
    }

    absent:{
      file {"/var/lib/mediawiki/wikis/${name}/":
        ensure  => absent;
        recurse => true, #FIXME it isn't removing the directory
      }

      file {"/etc/apache2/sites-available/${name}":
        ensure  => absent;
        require => Exec['disable-site'],
      }

      exec { 'disable-site':
        command => "/usr/sbin/a2dissite ${name}",
        onlyif  => "/bin/readlink -e /etc/apache2/sites-enabled/${name}",
        notify  => Exec['reload-apache2'];
      }
    }
  }
}

class apache::common {

  exec { 'reload-apache2':
    command     => '/etc/init.d/apache2 reload',
    refreshonly => true;
  }
}

class mediawiki::install {

  package { 'mediawiki':
    ensure => latest,
  }
  package { "mediawiki-extensions-openid":
    ensure => latest,
  }


  if ($targetdir) {
    file {'wikis':
      ensure  => 'link',
      name    => '/var/lib/mediawiki/wikis',
      target  => $targetdir,
      require => Package["mediawiki"];
    }
  } else {
    file { "wikis":
      ensure  => directory,
      path    => "/var/lib/mediawiki/wikis",
      mode    => 755,
      require => Package["mediawiki"];
    }
  }

}
