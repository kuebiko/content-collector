require 'active_record'
require 'yaml'
require 'byebug'
require 'kuebiko'

# recursively requires all files in ./lib and down that end in .rb
Dir.glob('lib/*.rb').each do |file|
  require_relative File.join(__dir__, '..', file)
end


database_config = YAML.load_file('config/database.yml')

# tells AR what db file to use
ActiveRecord::Base.establish_connection(database_config['database'])
