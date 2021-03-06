#
# Cookbook:: chef_cirta
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

package ['curl', 'git', 'python2.7', 'python-ldap', 'python-ipcalc', 'nbtscan', 'whois', 'cifs-utils', 'syslog-ng', 'python3-crypto', 'python3-httplib2', 'python3-ldap3']


timezone node[:chef_cirta][:timezone]

pip_packages = [['pytz', 'pytz'],
                ['splunk-sdk', 'splunklib'],
                ['paramiko==2.5.1', 'paramiko'],
                ['requests', 'requests'],
                ['simplejson', 'simplejson'],
                ['pySecurityCenter', 'securitycenter'],
                ['google-api-python-client', 'googleapiclient'],
                ['oauth2client', 'oauth2client'],
                ['httplib2', 'httplib2'],
                ['axonius-api-client', 'axonius_api_client'],
                ['pathlib2', 'pathlib2']
              ]

execute 'install_pip' do
  command 'curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py && python3 /tmp/get-pip.py --force-reinstall'
  not_if do ::File.exist?("/usr/local/bin/pip3") end
  action :run
end


pip_packages.each do |pip_name, pip_dir_name|
  execute "pip3_#{pip_name}" do
    command "pip3 install #{pip_name} --ignore-installed"
    not_if do ::Dir.exists?("/usr/local/lib/python3.5/dist-packages/#{pip_dir_name}") end
    action :run
  end
end

##########################
# Base directories
##########################

home_paths = node[:chef_cirta][:cirta_home].split('/')[1..-1]

home_path = '/'

home_paths.each do |dir|
  home_path += dir + "/"

  directory home_path do
    owner 'root'
    group node[:chef_cirta][:cirta_group]
    mode '0770'
    action :create
    not_if do ::Dir.exists?(home_path) end
  end

end

# Ensure leaf directory permissions remain in tact via recursive directory
directory node[:chef_cirta][:cirta_home] do
  owner 'root'
  group node[:chef_cirta][:cirta_group]
  mode '0770'
  action :create
  recursive true
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
        "#{node[:chef_cirta][:cirta_home]}/etc/users",
        "#{node[:chef_cirta][:cirta_home]}/plugins/local",
        "#{node[:chef_cirta][:cirta_home]}/plugins/local/actions",
        "#{node[:chef_cirta][:cirta_home]}/plugins/local/initializers",
        "#{node[:chef_cirta][:cirta_home]}/plugins/local/sources",
        "/var/log/cirta"
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
  directory "#{node[:chef_cirta][:cirta_home]}/etc/users/#{username}" do
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

##########################
# Logging cirta.log
##########################

template '/etc/syslog-ng/conf.d/cirta.conf' do
  source 'syslog-ng/cirta.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[syslog-ng]', :immediately
end

logrotate_app 'cirta_log' do
  path      node[:chef_cirta][:syslog_ng][:path]
  frequency 'daily'
  rotate    365
  create    "640 root #{node[:chef_cirta][:cirta_group]}"
end

service 'syslog-ng' do
  action :nothing
end


##########################
# Conf etc/local
##########################

confs = ['actions', 'attributes', 'cirta', 'initializers', 'playbooks', 'sources']

confs.each do |conf|

  template "#{node[:chef_cirta][:cirta_home]}/etc/local/#{conf}.conf" do
    cookbook "#{node[:chef_cirta][:implementation_cookbook]}"
    source "etc/local/#{conf}.conf.erb"
    owner 'root'
    group node[:chef_cirta][:cirta_group]
    mode '0640'
    sensitive true
  end

end


##########################
# Plugins local
##########################

['actions', 'initializers', 'sources'].each do |plugin_type|

  node[:chef_cirta][:plugins][:local][plugin_type].each do |plugin_name|

    template "#{node[:chef_cirta][:cirta_home]}/plugins/local/#{plugin_type}/#{plugin_name}.py" do
      cookbook "#{node[:chef_cirta][:implementation_cookbook]}"
      source "plugins/local/#{plugin_type}/#{plugin_name}.py.erb"
      owner 'root'
      group node[:chef_cirta][:cirta_group]
      mode '0640'
      sensitive true
    end

  end

end


##########################
# Resources
##########################


# node[:chef_cirta][:resources].each do |resource, resource_files|

#   directory "#{node[:chef_cirta][:cirta_home]}/resources/#{resource}" do
#     owner 'root'
#     group node[:chef_cirta][:cirta_group]
#     mode '0750'
#     action :create
#   end
  

#   resource_files.each do |resoucre_file|
#     template "#{node[:chef_cirta][:cirta_home]}/resources/#{resource}/#{resource_file}" do
#       cookbook "#{node[:chef_cirta][:implementation_cookbook]}"
#       source "resources/#{resource}/#{resource_file}.erb"
#       owner 'root'
#       group node[:chef_cirta][:cirta_group]
#       mode '0640'
#       sensitive true
#     end
#   end

# end

