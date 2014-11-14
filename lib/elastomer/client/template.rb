
module Elastomer
  class Client

    # Returns a Template instance.
    def template( name )
      Template.new self, name
    end


    class Template

      # Create a new template client for making API requests that pertain to
      # template management.
      #
      # client - Elastomer::Client used for HTTP requests to the server
      # name   - The name of the template as a String
      #
      def initialize( client, name )
        @client = client
        @name   = name
      end

      attr_reader :client, :name

      # Returns true if the template already exists on the cluster.
      def exists?
        client.cluster.templates.key? name
      end
      alias_method :exist?, :exists?

      # Get the template from the cluster.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-templates/
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def get( params = {} )
        response = client.get '/_template/{template}', update_params(params, :action => 'template.get')
        response.body
      end

      # Create the template on the cluster.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-templates/
      #
      # template - The template as a Hash or a JSON encoded String
      # params   - Parameters Hash
      #
      # Returns the response body as a Hash
      def create( template, params = {} )
        response = client.put '/_template/{template}', update_params(params, :body => template, :action => 'template.create')
        response.body
      end

      # Delete the template from the cluster.
      # See http://www.elasticsearch.org/guide/reference/api/admin-indices-templates/
      #
      # params - Parameters Hash
      #
      # Returns the response body as a Hash
      def delete( params = {} )
        response = client.delete '/_template/{template}', update_params(params, :action => 'template.delete')
        response.body
      end

      # Internal: Add default parameters to the `params` Hash and then apply
      # `overrides` to the params if any are given.
      #
      # params    - Parameters Hash
      # overrides - Optional parameter overrides as a Hash
      #
      # Returns a new params Hash.
      def update_params( params, overrides = nil )
        h = defaults.update params
        h.update overrides unless overrides.nil?
        h
      end

      # Internal: Returns a Hash containing default parameters.
      def defaults
        { :template => name }
      end
    end  # Template
  end  # Client
end  # Elastomer
