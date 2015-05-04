class ContentCollectionAgent < Kuebiko::Agent
  RESOURCE_TOPICS = [
    { topic: 'resources/twitter/tweet', klass: Kuebiko::MessagePayload::Document },
    { topic: 'resources/instagram/media', klass: Kuebiko::MessagePayload::Document }
  ]

  ENTITY_TOPICS = [
    { topic: 'entities/persona', klass: Kuebiko::MessagePayload::Persona }
  ]

  RELATIONSHIP_CLASS = Kuebiko::MessagePayload::ResourceRelationship
  RELATIONSHIP_TOPIC = 'resources/relationship'

  def initialize
    super
    
    # # Resources
    RESOURCE_TOPICS.each do |config|
      dispatcher.register_message_handler(
        config[:topic],
        config[:klass],
        method(:handle_resource)
      )
    end

    # Entities
    ENTITY_TOPICS.each do |config|
      dispatcher.register_message_handler(
        config[:topic],
        config[:klass],
        method(:handle_entity)
      )
    end

    # Relationship
    # dispatcher.register_message_handler(
    #   RELATIONSHIP_TOPIC,
    #   RELATIONSHIP_CLASS,
    #   method(:handle_relationship)
    # )
  end

  def handle_resource(msg)
    find_attrs = { source: msg.payload.source, source_id: msg.payload.source_id }
    content = msg.payload.to_hash.slice(*Resource.attribute_names.map(&:to_sym))

    Resource.where(find_attrs).first_or_create!(content)
  end

  def handle_entity(msg)
    find_attrs = { source: msg.payload.source, source_id: msg.payload.source_id }

    content = msg.payload.to_hash.slice(*Persona.attribute_names.map(&:to_sym))

    Persona.where(find_attrs).first_or_create!(content)
  end

  def handle_relationship(msg)
    # Find resources
    left_id = @mongo_client.collection('resources').find_one(
      type: msg.payload.start_resource.type,
      source: msg.payload.start_resource.source,
      source_id: msg.payload.start_resource.source_id
    )

    left_id = left_id['_id'] if left_id

    right_id = @mongo_client.collection('resources').find_one(
      type: msg.payload.end_resource.type,
      source: msg.payload.end_resource.source,
      source_id: msg.payload.end_resource.source_id
    )

    right_id = right_id['_id'] if right_id

    left_id = @mongo_client.collection('resources').insert(
      msg.payload.start_resource.serialize.merge(version_type: :partial)
    ) unless left_id

    right_id = @mongo_client.collection('resources').insert(
      msg.payload.end_resource.serialize.merge(version_type: :partial)
    ) unless right_id

    @mongo_client.collection('relationships').insert(
      { left_resource_id: left_id, right_resource_id: right_id, type: msg.payload.type }
    )

  end

  protected

  def upsert_message(msg, collection)
    hash = msg.payload.to_hash
    hash.each do |key, value|
      hash[key] = value.to_time.utc if value.is_a?(DateTime)
    end

    @mongo_client.collection(collection).update(
      { type: msg.payload.type, source: msg.payload.source, source_id: msg.payload.source_id },
      hash,
      upsert: true
    )
  end
end
