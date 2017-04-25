require 'data_mapper'
require 'config'

Config.load_and_set_settings(File.dirname(__FILE__) + '/../config/db.yml')
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, Settings.db_url)