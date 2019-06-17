#
# Cookbook:: chef_cirta
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

package ['git', 'python2.7', 'python-ldap', 'python-pip']


pip_packages = [['pytz', 'pytz'],
                ['splunk-sdk', 'splunklib'],
                ['paramiko', 'paramiko']]

pip_packages.each do |pip_name, pip_dir_name|
  execute "pip_#{pip_name}" do
    command "pip install #{pip_name}"
    not_if do ::Dir.exists?("/usr/local/lib/python2.7/dist-packages/#{pip_dir_name}") end
    action :run
  end
end

##########################
# Base directories
##########################

dirs = ['/nsm',
        '/nsm/scripts',
        '/nsm/scripts/python',
        '/nsm/scripts/python/cirta'
      ]

dirs.each do |dir|
  directory dir do
    owner 'root'
    group node[:chef_cirta][:cirta_group]
    mode '0770'
    action :create
  end
end


##########################
# Base directories
##########################

git node[:chef_cirta][:cirta_home] do
  repository 'https://github.com/chriswhitehat/cirta.git'
  reference 'master'
  user 'root'
  group node[:chef_cirta][:cirta_group]
  action :sync
end



##########################
# Local directories
##########################


dirs = ["#{node[:chef_cirta][:cirta_home]}/etc/local",
        "#{node[:chef_cirta][:cirta_home]}/plugins/local",
        "#{node[:chef_cirta][:cirta_home]}/plugins/local/actions",
        "#{node[:chef_cirta][:cirta_home]}/plugins/local/initializers",
        "#{node[:chef_cirta][:cirta_home]}/plugins/local/sources"
      ]

dirs.each do |dir|
  directory dir do
    owner 'root'
    group node[:chef_cirta][:cirta_group]
    mode '0770'
    action :create
  end
end




##########################
# Plugin __init__.py
##########################

['', '/actions', '/initializers', '/sources'].each do |plugin_type|
  file "#{node[:chef_cirta][:cirta_home]}/plugins/local#{plugin_type}/__init__.py" do
    action :create
    owner 'root'
    group node[:chef_cirta][:cirta_group]
    mode '0640'
  end
end


##########################
# User directories
##########################

node[:users].each do |username|
  directory "#{node[:chef_cirta][:cirta_home]}/etc/#{username}" do
    owner username
    group username
    mode '0700'
    action :create
    only_if do ::Dir.exists?("/home/#{username}") end
  end
end


##########################
# Cirta Symlink
##########################

link '/usr/local/bin/cirta' do
  to "#{node[:chef_cirta][:cirta_home]}/cirta.py"
end

