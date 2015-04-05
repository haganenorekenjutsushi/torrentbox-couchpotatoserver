#
# Cookbook Name:: couchpotatoserver
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Ensure the prerequisites are installed
log "Checking SickRage prerequisites for #{node['platform']}"
node['couchpotatoserver']['prerequisites']['linux'].each do |prereq|
	log "Processing #{prereq}"
	apt_package prereq do
	  action :install
	end
end

# Ensure we've got a service account
user node['couchpotatoserver']['config']['user'] do
  supports :manage_home => true
  gid "users"
  home "/home/#{node['couchpotatoserver']['config']['user']}"
  shell "/bin/bash"
  password node['couchpotatoserver']['config']['password']
end

# Control the installation & data dirs
[node['couchpotatoserver']['config']['path'],node['couchpotatoserver']['config']['datadir']].each do |path|
	directory path do
	  owner node['couchpotatoserver']['config']['user']
	  group 'user'
	  mode '0755'
	  action :create
	end
end

# Assume ownership of the contents of the data directory (useful when populating a backup in another recipe)
execute "own-datadir-couchpotato" do
  command <<-EOH    
  chown -R #{node['couchpotatoserver']['config']['user']} #{node['couchpotatoserver']['config']['datadir']}
  EOH
end

log "Fetching latest GIT repo"
git node['couchpotatoserver']['config']['path'] do
  user node['couchpotatoserver']['config']['user']
	repository node['couchpotatoserver']['repo']
	revision node['couchpotatoserver']['config']['branch']
	action :export
end

# Copy init from repo to init.d
file "/etc/init.d/couchpotato" do
  owner 'root'
  group 'root'
  mode '755'
  content lazy {::File.open("#{node['couchpotatoserver']['config']['path']}/#{node['couchpotatoserver']['init']['ubuntu']}").read}
end

# Control the call file
template '/etc/default/couchpotato'  do
	source 'ubuntu.default.erb'
	variables({
		:user => node['couchpotatoserver']['config']['user'],
		:home => node['couchpotatoserver']['config']['path'],
		:data => node['couchpotatoserver']['config']['datadir'],
		:opts => node['couchpotatoserver']['config']['options'],
		:pidfile => "/var/run/couchpotato/couchpotato.pid"
	})
end

# Control the PID dir
directory "/var/run/couchpotato" do
  owner node['couchpotatoserver']['config']['user']
  mode '0755'
  action :create
end

# Start the service
log "Starting couchpotato"
service "couchpotato" do
  action :start
end