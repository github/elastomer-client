require 'forwardable'

module Elastomer

  # The Index class is a decorator around a Tire::Index instance. This class
  # can either be used standalone or as a superclass for a more specific
  # instance.
  #
  # We are decorating the Tire::Index so we can add things such as metrics
  # tracking (number of requests, request time, etc) and error tracking via
  # failbot.
  #
  class Index
    extend Forwardable

    # Create a new Index that will search and store documents in the `name'
    # ElasticSearch index.
    #
    # name - The String name of the ElastiSearch index to operate on.
    #
    def initialize( name = nil )
      name = self.class.index_name if name.nil?
      @index = Tire::Index.new name
    end

    def_delegators :@index,
        :name, :url, :response, :exists?, :delete, :add_alias, :remove_alias, :aliases,
        :mapping, :settings, :bulk_store, :retrieve, :refresh, :open, :close, :analyze

    # Public: Create the index on the ElasticSearch cluster. If the class
    # method `mappings` exists it will be called and the returned value will
    # be used as the document type mappings for the index. Likewise, if the
    # class method `settings` exists it will be called and the returned value
    # will be used for the index settings during creation.
    #
    # opts - The options Hash
    #        :mappings - the Hash containing the document type mappings
    #        :settings - the Hash containing the index settings
    #
    # Returns the create operation result Hash from the ElasticSearch cluster.
    #
    def create( opts = {} )
      opts[:mappings] = self.class.mappings if self.class.respond_to? :mappings and not opts.key? :mappings
      opts[:settings] = self.class.settings if self.class.respond_to? :settings and not opts.key? :settings
      @index.create(opts)
    end

    # Public: Count the number of documents in the search index that match the
    # given query.
    #
    # query - The query Hash.
    # args  - Optional list of type to restrict the query to.
    #
    # Returns the number of matching documents.
    #
    def count( query, *args )
      json = MultiJson.encode(query.to_hash)
      type = EscapeUtils.escape_url(args.join(','))
      url  = "#{self.url}/#{[type, '_count'].join('/')}"

      result = Tire::Configuration.client.get(url, json)
      MultiJson.decode(result.body) if result.success?
    ensure
      curl = %Q|curl -X GET "#{url}" -d '#{json}'|
      @index.logged('/', curl)
    end

    # Public:
    #
    # obj -
    #
    # Returns the response body as a Hash.
    #
    def store( obj )
      if obj.is_a? Adapter
        if obj.respond_to? :each
          ary = []
          obj.each do |action, document|
            ary << [action, document]
            if ary.length >= 200
              bulk(*ary)
              ary.clear
            end
          end
          return bulk(*ary)
        end

        obj = obj.to_hash
        return if obj.nil?
      end

      @index.store(obj)
    end

    # Public:
    #
    # Returns the response body as a Hash.
    #
    def remove( *args )
      if args.first.is_a? Adapter
        adapter = args.first

        if adapter.respond_to? :delete_query
          query, *types = adapter.delete_query
          types << adapter.document_type if types.empty?
          return remove_by_query(query, *types)
        end

        args = [adapter.document_type, adapter.document_id]
      end

      @index.remove(*args)
    end

    # Public: Delete all documents from the index that match the given query.
    #
    # query - The query Hash.
    # args  - Optional list of type to restrict the query to.
    #
    # Returns the response body as a Hash.
    #
    def remove_by_query( query, *args )
      json   = MultiJson.encode(query.to_hash)
      source = EscapeUtils.escape_url(json)
      type   = EscapeUtils.escape_url(args.join(','))
      url    = "#{self.url}/#{type}/_query?source=#{source}"

      result = Tire::Configuration.client.delete(url)
      MultiJson.decode(result.body) if result.success?
    ensure
      curl = %Q|curl -X DELETE '#{url}'|
      @index.logged('/', curl)
    end

    # Public: Perform bulk indexing and deltion operations on the current
    # index. The operations are passed to this method as an Array of tuples.
    # Each tuple contains the action to take (:index, :delete) and the
    # document. For the :delete action, the document need only contain the
    # :_id and the :_type to be removed from the index.
    #
    # args - An Array of tuples containing [:action, {document}]
    #
    # Returns the response body as a Hash.
    #
    def bulk( *args )
      return if args.empty?
      payload = []

      args.each do |action, document|
        type = @index.get_type_from_document(document, :escape => false) # Do not URL-escape the _type
        id   = @index.get_id_from_document(document)

        case action
        when :index, 'index', :store, 'store'
          payload << MultiJson.encode({:index => {:_index => name, :_type => type, :_id => id}})
          payload << @index.convert_document_to_json(document)

        when :delete, 'delete', :remove, 'remove'
          payload << MultiJson.encode({:delete => {:_index => name, :_type => type, :_id => id}})

        else
          raise "WTF?"
        end
      end

      payload << nil
      payload = payload.join("\n")

      tries = 5
      count = 0

      begin
        response = Tire::Configuration.client.post("#{self.url}/_bulk", payload)
        raise RuntimeError, "#{response.code} > #{response.body}" if response.failure?
        response
      rescue StandardError => error
        if count < tries
          count += 1
          STDERR.puts "[ERROR] #{error.message}, retrying (#{count})..."
          retry
        else
          STDERR.puts "[ERROR] Too many exceptions occured, giving up. The HTTP response was: #{error.message}"
          raise
        end

      ensure
        curl = %Q|curl -X POST "#{self.url}/_bulk" -d '{... data omitted ...}'|
        @index.logged('BULK', curl)
      end
    end

    # Construct a term filter for the given field and value. If the value is
    # an Array, then a term filter will be constructed for each item in the
    # Array.
    #
    # field - The field name as a String or Symbol.
    # value - The term as a String or an Array of Strings.
    #
    # If the field name is prefixed with a negative `-`, then a **not** filter
    # will be generated and returned.
    #
    # Examples
    #
    #   build_term_filter( :language, 'Ruby' )
    #   #=> { :term => { :language => 'Ruby' } }
    #
    #   build_term_filter( :language, ['Ruby', 'JavaScript', 'C'] )
    #   #=> { :terms => { :language => ['Ruby', 'JavaScript', 'C'] }}
    #
    #   build_term_filter( '-language', 'Ruby' )
    #   #=> { :not => { :filter => { :term => { :language => 'Ruby' }}}}
    #
    # Returns the filter Hash or nil if a filter could not be created.
    #
    def build_term_filter( field, value )
      field, negate = check_for_negative_field(field)

      filter =
          if value.is_a? Array
            return if value.empty?
            { :terms => { field => value } }
          else
            value = value.to_s
            return if value.empty?
            { :term => { field => value } }
          end

      if negate
        not_filter(filter)
      else
        filter
      end
    end

    # Construct a range filter expression for the given field and value. The
    # value should follow the Solr syntax expressing the low and high values
    # in sqaure brackes - '[low TO high]'. Either value can be a '*'
    # indicating that it is unlimited. The low and high values should NOT
    # contain any whitespace characters.
    #
    # If a plain value is given that does not conform to the '[low TO high]'
    # syntax then a term filter will be returned. If both the low and high
    # values are unlimited - '[* TO *]' - then `nil` will be returned.
    #
    # If the field name is prefixed with a negative `-`, then a **not** filter
    # will be generated and returned.
    #
    # field - The field name as a String or Symbol.
    # value - The range as a String or an Array of Strings.
    #
    # Examples
    #
    #   build_range_filter( :followers, '42' )
    #   #=> { :term => { :followers => '42' }}
    #
    #   build_range_filter( :followers, '[20 TO *]' )
    #   #=> { :range => { :followers => { :from => '20' }}}
    #
    #   build_range_filter( :repos, '[* TO 100]' )
    #   #=> { :range => { :repos => { :to => '100' }}}
    #
    #   build_range_filter( :forks, '[10 TO 100]' )
    #   #=> { :range => { :forks => { :from => 10, :to => '100' }}}
    #
    #   build_range_filter( :forks, '[* TO *]' )
    #   #=> nil
    #
    #   build_range_filter( :forks, ['[* TO 10]', '[100 TO *]'] )
    #   #=> { :or => [
    #   #       { :range => { :forks => { :to => '10' }}},
    #   #       { :range => { :forks => { :from => '100' }}}
    #   #   ]}
    #
    # Returns the filter Hash or nil if a filter could not be created.
    #
    def build_range_filter( field, value )
      field, negate = check_for_negative_field(field)

      filter =
          if value.is_a? Array
            ary = value.map { |v| build_range_filter(field, v) }
            ary.compact!
            return if ary.empty?
            { :or => ary }
          else
            m = /^\[(\S+)\s+TO\s+(\S+)\]/.match(value.to_s)
            if m
              from, to = m.captures
              opts = {}
              opts[:from] = from if from != '*'
              opts[:to]   = to if to != '*'

              return if opts.empty?
              { :range => { field => opts } }
            else
              build_term_filter(field, value)
            end
          end

      if negate
        not_filter(filter)
      else
        filter
      end
    end

    # Construct a query string filter. The query will be run against the
    # given field. The default operator for the query terms is AND; all words
    # in the query phrase must be present for a match.
    #
    # "capital AND of AND Hungary" as opposed to "capital OR of OR Hungary".
    #
    # If the field name is prefixed with a negative `-`, then a **not** filter
    # will be generated and returned.
    #
    # field - The field name as a String or Symbol.
    # value - The query as a String.
    #
    # Examples
    #
    #   build_query_filter( :location, "Boulder, CO" )
    #   #=> { :query => { :query_string => { :query => "Boulder, CO", :default_field => :location }}}
    #
    #   build_query_filter( :location, ["Boulder, CO", "San Francisco"] )
    #   #=> { :or => [
    #   #       { :query => { :query_string => { :query => "Boulder, CO",   :default_field => :location }}},
    #   #       { :query => { :query_string => { :query => "San Francisco", :default_field => :location }}}
    #   #   ]}
    #
    # Returns the filter Hash or nil if a filter could not be created.
    #
    def build_query_filter( field, value )
      field, negate = check_for_negative_field(field)

      filter =
          if value.is_a? Array
            ary = value.map { |v| build_query_filter(field, v) }
            ary.compact!
            return if ary.empty?
            { :or => ary }
          else
            query = ::Elastomer.escape_characters(value)
            return if query.empty?
            {:query => {:query_string => {:query => query, :default_field => field, :default_operator => :AND }}}
          end

      if negate
        not_filter(filter)
      else
        filter
      end
    end

    # Construct a prefix filter for the given field and value. If the value is
    # an Array, then a prefix filter will be constructed for each item in the
    # Array.
    #
    # If the field name is prefixed with a negative `-`, then a **not** filter
    # will be generated and returned.
    #
    # field - The field name as a String or Symbol.
    # value - The term as a String or an Array of Strings.
    #
    # Examples
    #
    #   build_prefix_filter( :path, 'Ruby' )
    #   #=> { :prefix => { 'path' => 'Ruby' }}
    #
    #   build_prefix_filter( :path, ['vendor/', 'bin/'] )
    #   #=> { :terms => { 'path' => ['vendor/', 'bin/'] }}
    #
    #   build_prefix_filter( '-path', 'Ruby' )
    #   #=> { :not => { :filter => { :prefix => { 'path' => 'Ruby' }}}}
    #
    # Returns the filter Hash or nil if a filter could not be created.
    #
    def build_prefix_filter( field, value )
      field, negate = check_for_negative_field(field)

      filter =
          if value.is_a? Array
            ary = value.map { |v| build_prefix_filter(field, v) }
            ary.compact!
            return if ary.empty?
            { :or => ary }
          else
            value = value.to_s
            return if value.empty?
            { :prefix => { field => value } }
          end

      if negate
        not_filter(filter)
      else
        filter
      end
    end

    # Convert the given filter into a **not** version of the filter.
    #
    # filter - A filte Hash
    #
    # Returns the **not** version of the filter Hash.
    #
    def not_filter( filter )
      { :not => { :filter => filter }}
    end

    # Determine if the given field represents a **not** query (a negative
    # query) on the field. If so, return the field name and `false` as a
    # tuple. Otherwise just return the field name.
    #
    # This method simply checks for the presence of a negative `-` sign at the
    # beginning of the field name. It will be stripped when the field name is
    # returned.
    #
    # field - The field name as a String or Symbol
    #
    # Returns either a tuple of ["field", true] or just "field".
    #
    def check_for_negative_field( field )
      field = field.to_s
      if field =~ %r/^-(.*)/
        [$1, true]
      else
        field
      end
    end

  end  # Index
end  # Elastomer
