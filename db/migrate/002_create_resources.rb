class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.string    :language_code

      t.string    :agent
      t.datetime  :agent_captured_at
      t.string    :source
      t.string    :source_id

      t.integer   :version
      t.string    :version_type

      t.json      :geolocation

      t.string    :mime_type
      t.string    :content
      t.string    :keywords, array: true, default: []
      t.json      :metadata

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
