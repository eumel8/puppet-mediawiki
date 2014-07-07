Mediawiki farm module
=======================================

Puppet Module to create many wikis (on the same machine) using only one mediawiki installation.

Prerequisites
-------------

puppet module for apache (i.e. https://github.com/puppetlabs/puppetlabs-apache)

puppet module for memcached (i.e. https://github.com/saz/puppet-memcached)

MySQL database connection


Usage
-----

Parameters available::

    mediawiki::new { "Name":
      ensure      => present, | enabled, | disabled, | absent,
      admin       => 'foo@bar.com',
      servername  => 'foo.bar.com',      #Default to $name
      serveralias => 'foo',              #Default to $name
      ip          => '127.0.0.1',        #IP for apache configuration. Default to *
      port        => 80                  #Port for apache configuration. Default to 80
    }


Example
-------

    node 'wiki.example.com' {

      class {'apache':}
      class {'memcached':}

      mediawiki::new { "wiki1.example.com":
        ensure      => present,
        admin       => 'wikimaster@example.com',
        servername  => 'wiki1.example.com',
        serveralias => 'wiki1',
        ip          => '192.168.1.2', 
        targetdir   => '/data/wikis'
      }

      mediawiki::new { "wiki2.example.com":
        ensure      => present,
        admin       => 'wikimaster@example.com',
        servername  => 'wiki2.example.com',
        serveralias => 'wiki2',
        ip          => '192.168.1.2', 
        targetdir   => '/data/wikis'
      }

    }


Notes
-----

* Tested OS: Ubuntu 9.10, 10.04.1 LTS 12.04 LTS
* Tested Mediawiki versions: 1:1.15.0-1.1ubuntu0.4, 1:1.15.1-1ubuntu2.1
