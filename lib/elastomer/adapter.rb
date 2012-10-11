module Elastomer

  # The Adapter class provides some common functionality that can be used for
  # creating your own data adapters. The whole point of an adapter is to take
  # a data model - an ActiveRecord instance, for example - and extract
  # information into a document suitable for indexing in ElasticSearch.
  #
  class Adapter

    # Public: Returns the document type for the adapter.
    #
    # Returns the document type as a String.
    #
    def self.document_type
      return @type if defined? @type

      @type = name.split('::').last
      @type.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      @type.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      @type.tr!('-', '_')
      @type.downcase!
      @type
    end

    # Public: Create a new adapter instance given a database ID or a data
    # model instance (ActiveRecord).
    #
    # model_or_id - The database ID number (String or Integer) or the data
    #               model instance
    #
    # Returns an adapter instance.
    #
    def self.create( model_or_id, *args )
      obj = self.new

      case model_or_id
      when String, Integer
        obj.document_id = Integer(model_or_id)
      else
        obj.model = model_or_id
      end

      obj
    end

    # The ID of the document. This will be used as the ElasticSearch ID for
    # the document.
    attr_accessor :document_id

    # Public: Returns the document type for the adapter.
    #
    # Returns the document type as a String.
    #
    def document_type
      self.class.document_type
    end

    # Public: Accessor for the data model instance. Subclasses should override
    # this method and generate the model from the document_id if the model has
    # not already been set. Otherwise this method will raise a
    # NotImplementedError, and no one wants that to happen.
    #
    # Returns the data model instance.
    # Raises a NotImplementedError if the model has not been set.
    #
    def model
      return @model if defined? @model
      raise NotImplementedError,
            "The superclass does not know how to instantiate your model. Bad developer - no latte!"
    end

    # Public: Set the data model for the adapter. The data model object must
    # respond to the `id` method. The `document_id` will be set to the return
    # value of this id method.
    #
    def model=( model )
      @model = model
      @document_id = model.id
    end

  end  # Adapter
end  # Elastomer
