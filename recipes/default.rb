#
# Cookbook:: chef_cirta
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

package ['git', 'python2.7', 'python-ldap', 'python-pip']


pip_packages = [('pytz', 'pytz'),
                ('splunk-sdk', 'splunklib'),
                ('paramiko', 'paramiko')]

pip_packages.each do |pip_name, pip_dir_name|
  execute "pip_#{pip_name}" do
    command "pip install #{pip_name}"
    not_if do ::Dir.exists?("/usr/local/lib/python2.7/dist-packages/#{pip_dir_name}") end
    action :run
  end
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
  repository 'https://github.com/chriswhitehat/cirta.git'
  reference 'master'
  user 'root'
  group 'ir'
  action :sync
end
