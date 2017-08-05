#
# Cookbook:: solr
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Creating solr group
group node['solr']['GROUP'] do
  gid node['solr']['USER_GID']
end

# Creating solr user
user node['solr']['USER'] do
  comment 'Solr service user'
  uid node['solr']['USER_UID']
  gid node['solr']['USER_GID']
  home node['solr']['USER_HOME']
  shell node['solr']['USER_SHELL']
end


directory node['solr']['USER_HOME'] do
  owner node['solr']['USER']
  group node['solr']['GROUP']
  action :create
end

package 'lsof' do
  action :install
end



# installing java package temporarily
########################################
package 'java-1.8.0-openjdk.x86_64' do
  action :install
end

execute "Set Java home" do
    command <<-EOF
        echo "export JAVA_HOME=/etc/alternatives/jre_openjdk" >> /etc/profile
        export JAVA_HOME=/etc/alternatives/jre_openjdk
    EOF
    only_if { `grep "^export JAVA_HOME=/etc/alternatives/jre_openjdk" /etc/profile` == "" }
end

execute "sourcing /etc/profile" do
    command <<-EOF
        source /etc/profile
    EOF
end

###########################################


# Copy solr package to root home folder
cookbook_file "/root/"+node['solr']['INSTALL_PACKAGE'] do
  source node['solr']['INSTALL_PACKAGE']
  owner 'root'
  group 'root'
  mode '0700'
end


# Making sure storage is available
directory node['solr']['MOUNTED_STORAGE'] do
  owner 'root'
  group 'root'
  action :create
end


# Removing existing solr
execute 'Removing old solr' do
  user 'root'
  cwd '/root'
  command <<-EOF
       service #{node['solr']['SERVICE']} stop
       rm -rf #{node['solr']['INSTALL_PATH']}/solr
       rm -rf /etc/default/solr.in.sh
       rm -rf /etc/init.d/solr
  EOF
end


# Installing Solr package as a service
execute 'Installing solr' do
  user 'root'
  cwd '/root'
  command <<-EOF
       tar -xzf #{node['solr']['INSTALL_PACKAGE']} #{node['solr']['SERVICE_INSTALL_SH']} --strip-components=2
       bash ./install_solr_service.sh #{node['solr']['INSTALL_PACKAGE']} -i #{node['solr']['INSTALL_PATH']} -d /var/solr -u #{node['solr']['USER']} -s #{node['solr']['SERVICE']} -p #{node['solr']['SOLR_PORT']}
       service #{node['solr']['SERVICE']} stop
  EOF
  only_if { `find /etc/default/ -name "solr.in.sh"` == "" }
end


# Moving solr data folder to storage and creating Node folder
###############################################################

lastOctet = node['ipaddress'].split('.')[3]

storageDataFolder = node['solr']['MOUNTED_STORAGE']+"/"+node['solr']['SHORT_HOST_NAME']
nodeDataFolder = storageDataFolder+"/Node"+lastOctet

directory storageDataFolder do
  owner 'root'
  group 'root'
  action :create
end

directory nodeDataFolder do
  owner 'root'
  group 'root'
  action :create
end

execute 'Moving solr data folder to storage' do
  user 'root'
  cwd '/root'
  command <<-EOF
    mv /var/solr/data/* #{nodeDataFolder+"/"}
    rm -rf /var/solr/data
    ln -s #{storageDataFolder} /var/solr/data
    chown -R #{node['solr']['USER']+":"+node['solr']['GROUP']} /var/solr
  EOF
end

# End of Moving solr data folder to storage and creating Node folder
###############################################################


# Placing Solr main config file
template '/etc/default/solr.in.sh' do
  source 'solr.in.sh.erb'
  owner 'root'
  group 'root'
  mode '0744'
end


# Start of Nasdaq Configurations
########################################

# Create Nasdaq folder
directory node['solr']['COMPANY_DIR'] do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
end


# create App Folder
directory node['solr']['APP_DIR'] do
  mode '0755'
  owner 'root'
  group 'root'
  action :create
end

# Placing basic files on App Folder
execute 'Creating basic config files for APP' do
  user 'root'
  cwd node['solr']['App_DIR']
  command <<-EOF
       cp -rf ../basic_configs/* ./
  EOF
end

# Placing App config file
cookbook_file "#{node['solr']['APP_DIR']}/conf/solrconfig.xml" do
  source 'solrconfig.xml'
  owner 'root'
  group 'root'
  mode '0644'
end

# Placing Managed Schema file
cookbook_file "#{node['solr']['APP_DIR']}/conf/managed-schema" do
  source 'managed-schema'
  owner 'root'
  group 'root'
  mode '0644'
end

# Placing Stopwords file
cookbook_file "#{node['solr']['APP_DIR']}/conf/stopwords.txt" do
  source 'stopwords.txt'
  owner 'root'
  group 'root'
  mode '0644'
end

# End of Nasdaq Configurations
########################################


execute 'Starting solr service' do
  user 'root'
  cwd '/root'
  command <<-EOF
    service #{node['solr']['SERVICE']} start
  EOF
end
