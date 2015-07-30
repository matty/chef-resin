resin_user = node[:resin][:user]
resin_alias = node[:resin][:home]
resin_base_dir = node[:resin][:base_dir]
resin_directory = "#{resin_base_dir}/resin-pro-#{node[:resin][:version]}"
resin_file = "#{Chef::Config[:file_cache_path]}/resin-pro-#{node[:resin][:version]}.tar.gz"
maven_search_path = "http://search.maven.org/remotecontent?filepath="
packages = %w( htop tree wget pcre )

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

# Install all packages.
packages.each do |library|
  package library
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

execute 'link resin' do
  command "ln -sf #{resin_directory} #{resin_alias}"
  user resin_user
end

directory "#{resin_alias}/ext-lib" do
  recursive true
  owner resin_user
end

bash 'install resin' do
  code <<-EOH
./configure --prefix=#{resin_directory}
make
make install
  EOH
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

unless data_bag('resin').empty?
  unless data_bag_item('resin', 'licenses').empty?
    data_bag_item('resin', 'licenses')['license_keys'].each do |license_key,license_value|
      file "#{resin_directory}/licenses/#{license_key}.license" do
        content license_value
        backup 0
      end
    end
  end
end

unless node[:resin][:sqlitejdbc].nil?
  sqlite_version = node[:resin][:sqlitejdbc][:version]
  remote_file 'install sqlitejdbc' do
    path "#{resin_alias}/ext-lib/sqlite-jdbc-#{sqlite_version}.jar"
    source "#{maven_search_path}org/xerial/sqlite-jdbc/#{sqlite_version}/sqlite-jdbc-#{sqlite_version}.jar"
  end
end

unless node[:resin][:postgresql].nil?
  psql_version = node[:resin][:postgresql][:version]
  remote_file 'install progresql jdbc' do
    path "#{resin_alias}/ext-lib/postgresql-#{psql_version}.jar"
    source "#{maven_search_path}org/postgresql/postgresql/#{psql_version}/postgresql-#{psql_version}.jar"
  end
end

unless node[:resin][:postgis].nil?
  postgis_jdbc_version = node[:resin][:postgis][:jdbc][:version]
  remote_file 'install postgis jdbc' do
    path "#{resin_alias}/ext-lib/postgis-jdbc-#{postgis_jdbc_version}.jar"
    source "#{maven_search_path}org/postgis/postgis-jdbc/#{postgis_jdbc_version}/postgis-jdbc-#{postgis_jdbc_version}.jar"
  end

  postgis_stubs_version = node[:resin][:postgis][:stubs][:version]
  remote_file 'install postgis stubs' do
    path "#{resin_alias}/ext-lib/postgis-stubs-#{postgis_stubs_version}.jar"
    source "#{maven_search_path}org/postgis/postgis-stubs/#{postgis_stubs_version}/postgis-stubs-#{postgis_stubs_version}.jar"
  end
end