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
