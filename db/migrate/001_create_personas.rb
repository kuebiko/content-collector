class CreatePersonas < ActiveRecord::Migration
  def self.up
    create_table :personas do |t|
      t.string :language_code

      t.string :agent
      t.string :source
      t.string :source_id
      t.string :description

      t.json :geolocation
      t.json :content

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
