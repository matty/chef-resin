default[:resin][:user] = Etc.getlogin
default[:resin][:base_dir] = Dir.home(node[:resin][:user])
default[:resin][:version] = '4.0.41'
default[:resin][:sqlitejdbc][:version] = '3.8.5-pre1'
default[:resin][:postgresql][:version] = '9.4-1201-jdbc41'