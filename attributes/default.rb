default[:java][:jdk_version] = 7
default[:resin][:user] = Etc.getlogin
default[:resin][:home] = File.join(Dir.home(node[:resin][:user]), 'resin')
default[:resin][:base_dir] = File.expand_path("..", node[:resin][:home])
default[:resin][:version] = '4.0.41'
default[:resin][:sqlitejdbc][:version] = '3.8.5-pre1'
default[:resin][:postgresql][:version] = '9.4-1201-jdbc41'