require_relative 'config/environment'

namespace :db do
  desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"
  task :migrate do
    # https://gist.github.com/Andyvanee/1232513
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end

  task :create do
    database_config = YAML.load_file('config/database.yml')

    ActiveRecord::Base.logger = Logger.new(File.open( File.join(ROOT_DIR, 'log', 'database.log'), 'a'))
    ActiveRecord::Base.establish_connection(database_config['database'].reject {|k,v| k == 'database'})
    ActiveRecord::Base.connection.create_database database_config['database']['database']
  end
end
