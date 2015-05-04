require 'active_record'
require 'yaml'
require 'byebug'
require 'kuebiko'
require 'logger'
require "awesome_print"

ROOT_DIR = File.join(__dir__, '..')

# recursively requires all files in ./lib and down that end in .rb
Dir.glob('lib/**/*.rb').each do |file|
  require_relative File.join(ROOT_DIR, file)
end

database_config = YAML.load_file('config/database.yml')

# tells AR what db file to use
ActiveRecord::Base.logger = Logger.new(File.open( File.join(ROOT_DIR, 'log', 'database.log'), 'a'))
ActiveRecord::Base.establish_connection(database_config['database'])
