#
# Cookbook:: chef_cirta
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.


default[:chef_cirta][:implementation_cookbook] = 'org_cirta'
default[:chef_cirta][:cirta_home] = '/opt/cirta'
default[:chef_cirta][:cirta_group] = 'ir'

default[:chef_cirta][:plugins][:local][:actions] = []
default[:chef_cirta][:plugins][:local][:initializers] = []
default[:chef_cirta][:plugins][:local][:sources] = []

default[:chef_cirta][:syslog_ng][:enabled] = false
default[:chef_cirta][:syslog_ng][:listen_ip] = '127.0.0.1'
default[:chef_cirta][:syslog_ng][:port] = '10514'
default[:chef_cirta][:syslog_ng][:path] = '/var/log/cirta/cirta.log'

default[:chef_cirta][:timezone] = 'UTC'
