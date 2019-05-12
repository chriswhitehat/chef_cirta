#
# Cookbook:: chef_cirta
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

group 'ir' do
  action :create
  gid 999
end


dirs = ['/nsm',
        '/nsm/scripts',
        '/nsm/scripts/python',
        '/nsm/scripts/python/cirta']

dirs.each do |dir|
  directory dir do
    owner 'root'
    group 'ir'
    mode '0770'
    action :create
  end
end

git '/nsm/scripts/python/cirta' do
  repository 'https://github.com:chriswhitehat/cirta.git'
  reference 'master'
  user 'root'
  group 'ir'
  action :sync
end
