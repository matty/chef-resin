resin_user = node[:resin][:user]
resin_alias = node[:resin][:home]
resin_base_dir = node[:resin][:base_dir]
resin_directory = "#{resin_base_dir}/resin-pro-#{node[:resin][:version]}"
resin_file = "#{Chef::Config[:file_cache_path]}/resin-pro-#{node[:resin][:version]}.tar.gz"
resin_apache2 = node[:resin][:apache2]
resin_apache2_dir = node[:resin][:apache2_dir]
maven_search_path = "http://search.maven.org/remotecontent?filepath="

directory resin_base_dir do
  owner resin_user
end

include_recipe 'build-essential'
include_recipe 'java'

if platform_family?('rhel')
  include_recipe 'yum-epel'

  yum_repository('ELGIS') do
    description 'Enterprise Linux GIS'
    enabled true
    gpgcheck true
    baseurl 'http://elgis.argeo.org/repos/6/elgis/x86_64/'
    gpgkey 'http://elgis.argeo.org/RPM-GPG-KEY-ELGIS'
  end
end

remote_file resin_file do
  source "http://caucho.com/download/resin-pro-#{node[:resin][:version]}.tar.gz"
  not_if { ::File.exists?(resin_file) }
end

execute 'untar resin' do
  command "tar -xzf #{resin_file} --directory #{resin_base_dir}"
  creates resin_directory
  user resin_user
  not_if { ::File.exists?(resin_directory) }
end

link resin_alias do
  to resin_directory
  user resin_user
end

directory "#{resin_alias}/ext-lib" do
  recursive true
  owner resin_user
end

bash 'install resin' do

if resin_apache2
  code <<-EOH
./configure --prefix=#{resin_directory} --with-apache=#{resin_apache2_dir}
make
make install
  EOH
else
  code <<-EOH
./configure --prefix=#{resin_directory}
make
make install
  EOH
end
  cwd resin_directory
  user resin_user
  not_if do
    if platform_family?('mac_os_x')
      File::exist?("#{resin_directory}/libexec64/libresin.jnilib")
    else
      File::exist?("#{resin_directory}/libexec64/libresin.so")
    end
  end
end

begin
  data_bag_item('resin', 'licenses')['license_keys'].each do |license_key, license_value|
    file "#{resin_directory}/licenses/#{license_key}.license" do
      content license_value
      backup 0
    end
  end
rescue
  # Ignore if data bag doesn't exist
end

unless node[:resin][:mysql][:connector][:version].nil?
  mysql_connector_version = node[:resin][:mysql][:connector][:version]
  remote_file 'install mysql connector' do
    path "#{resin_alias}/ext-lib/mysql-connector-java-#{mysql_connector_version}.jar"
    source "#{maven_search_path}mysql/mysql-connector-java/#{mysql_connector_version}/mysql-connector-java-#{mysql_connector_version}.jar"
  end
end
