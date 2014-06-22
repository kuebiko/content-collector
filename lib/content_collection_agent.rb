require 'mongo'
require 'byebug'

class ContentCollectionAgent < Kuebiko::Agent
  RESOURCE_CLASS = Kuebiko::MessagePayload::Document
  DOCUMENT_TOPICS = {twitter: 'resources/twitter/tweet'}

  def initialize
    super

    @mongo_client = Mongo::MongoClient.new.db('kuebiko')

    DOCUMENT_TOPICS.each do |handler, topic|
      dispatcher.register_message_handler(
        topic,
        RESOURCE_CLASS,
        method("handle_#{handler}".to_sym)
      )
    end
  end

  def handle_twitter(msg)
    hash = msg.payload.to_hash
    hash.each do |key, value|
      hash[key] = value.to_time.utc if value.is_a?(DateTime)
    end

    @mongo_client.collection('twitter').insert(hash)
  end
end
