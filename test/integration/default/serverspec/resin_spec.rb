require 'serverspec'

set :backend, :exec

user_home = Dir.home(Etc.getlogin)

describe file("#{user_home}/resin/ext-lib") do
  it { should be_directory }
end

describe file("#{user_home}/resin/ext-lib/postgresql-9.4-1201-jdbc41.jar") do
  it { should be_file }
end

describe file("#{user_home}/resin/ext-lib/sqlite-jdbc-3.8.5-pre1.jar") do
  it { should be_file }
end

describe file("#{user_home}/resin/licenses/5036210.license") do
  it { should be_file }
end

describe file("#{user_home}/resin/licenses/1146571.license") do
  it { should be_file }
end