# vim: set ft=ruby ai et ts=2 sw=2 :
user { 'Jo':
  ensure   => 'present',
  comment  => 'Created user with puppet',
  home     => '/home/Jo',
  shell    => '/bin/bash',
}
