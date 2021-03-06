# == Class: puppet::server::service
#
# Set up the puppet server as a service
#
# === Parameters:
#
# $app_root::      Rack application top-level directory
#
# $puppetmaster::  Whether to start/stop the (Ruby) puppetmaster service
#
# $puppetserver::  Whether to start/stop the (JVM) puppetserver service
#
# $rack::          Whether to manage restarts for the Rack-based puppetmaster service
#
class puppet::server::service(
  Optional[Stdlib::Absolutepath] $app_root = undef,
  Optional[Boolean] $puppetmaster = undef,
  Optional[Boolean] $puppetserver = undef,
  Optional[Boolean] $rack = undef,
) {
  if $puppetmaster and $puppetserver {
    fail('Both puppetmaster and puppetserver cannot be enabled simultaneously')
  }

  if $::osfamily == 'Debian' and (versioncmp($::puppetversion, '4.0') > 0) {
    $puppetmaster_service = 'puppet-master'
  } else {
    $puppetmaster_service = 'puppetmaster'
  }

  if $puppetmaster != undef {
    $pm_ensure = $puppetmaster ? {
      true  => 'running',
      false => 'stopped',
    }
    service { $puppetmaster_service:
      ensure => $pm_ensure,
      enable => $puppetmaster,
    }
  }

  if $puppetserver != undef {
    $ps_ensure = $puppetserver ? {
      true  => 'running',
      false => 'stopped',
    }
    service { 'puppetserver':
      ensure => $ps_ensure,
      enable => $puppetserver,
    }
  }

  if $rack {
    exec {'restart_puppetmaster':
      command     => "/bin/touch ${app_root}/tmp/restart.txt",
      refreshonly => true,
      cwd         => $app_root,
    }
  }
}
