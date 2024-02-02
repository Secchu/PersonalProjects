# vim: set ft=ruby ts=2 sw=2 et ai :
service { 'chrony':
  ensure => 'running',
  enable => true,
 }
