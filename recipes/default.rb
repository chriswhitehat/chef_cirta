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
        '/nsm/scripts/python'
      ]

dirs.each do |dir|
  directory dir do
    owner 'root'
    group 'ir'
    mode '0770'
    action :create
  end
end


##########################
# Base directories
##########################

git '/nsm/scripts/python/cirta' do
  repository 'https://github.com/chriswhitehat/cirta.git'
  reference 'master'
  user 'root'
  group 'ir'
  action :sync
end



##########################
# Local directories
##########################

dirs = ['/nsm',
        '/nsm/scripts',
        '/nsm/scripts/python',
        '/nsm/scripts/python/cirta',
        '/nsm/scripts/python/cirta/etc/local',
        '/nsm/scripts/python/cirta/plugins/local',
        '/nsm/scripts/python/cirta/plugins/local/actions',
        '/nsm/scripts/python/cirta/plugins/local/initializers',
        '/nsm/scripts/python/cirta/plugins/local/sources'
      ]

dirs.each do |dir|
  directory dir do
    owner 'root'
    group 'ir'
    mode '0770'
    action :create
  end
end


##########################
# Plugin __init__.py
##########################

['', '/actions', '/initializers', '/sources'].each do |plugin_type|
  file "/nsm/scripts/python/cirta/plugins/local#{plugin_type}/__init__.py" do
    action :create
    owner 'root'
    group 'ir'
    mode '0640'
  end
end


##########################
# User directories
##########################

node[:users].each do |username|
  directory "/nsm/scripts/python/cirta/etc/#{username}" do
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
  to '/nsm/scripts/python/cirta/cirta.py'
end


##########################
# Actions Conf
##########################

actions = data_bag_item('cirta', 'test')

template '/nsm/scripts/pythong/cirta/etc/local/actions.conf' do
  source 'actions.conf.erb'
  owner 'root'
  group 'ir'
  mode '0640'
  variables ({
    actions: actions
  })
end

