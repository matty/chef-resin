default[:java][:jdk_version] = 8
default[:resin][:user] = Etc.getlogin
default[:resin][:home] = File.join(Dir.home(node[:resin][:user]), 'resin')
default[:resin][:base_dir] = File.expand_path("..", node[:resin][:home])
default[:resin][:version] = '4.0.48'
default[:resin][:apache2] = false
default[:resin][:apache2_dir] = '/etc/apache2'
default[:resin][:mysql][:connector][:version] = '5.1.38'
