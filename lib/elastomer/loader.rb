module Elastomer

  # The Loader class encapsulates all the common logic for creating and index
  # and loading data from database models into an ElasticSearch index.
  #
  class Loader

    # The Logger used to track loading progress.
    attr_reader :logger

    # The Index this Loader will import data into.
    attr_reader :index

    # Create a new Loader capable of bulk-importing data into the given index.
    #
    # index - The Index to load data into.
    #
    def initialize( index )
      @index = index

      logfile = @index.class.index_name + '-load.log'
      @logger = Logger.new(logfile, File::WRONLY | File::APPEND)
      @logger.level = Logger::INFO
    end

    # Public: Create the index in ElasticSearch. If the index already exists
    # an error will be raised. You can override this behavior by setting
    # either the :delete option or the :force option to `true`. The :delete
    # option will remove and recreate the index. The :force option will simply
    # load data into an existing index. If both options are set to true, then
    # the :delete option takes precedence.
    #
    # opts - The Hash of options.
    #        :delete - set to `true` to delete and recreated an existing index
    #        :force  - set to `true` to forcibly load data into an existing index
    #
    # Examples
    #
    #   setup( index )
    #   #=> Loader instance
    #
    #   setup( index )
    #   #=> raises RuntimeError since 'users-repos' already exists
    #
    #   setup( index, :delete => true )
    #   #=> Loader instance
    #
    #   setup( index, :force => true )
    #   #=> Loader instance
    #
    #
    # Returns this Loader instance.
    # Raises RuntimeError if the index already exists.
    #
    def setup( opts = {} )
      msg = "Preparing to load data into #{index.name.inspect}"
      $stdout.puts msg
      logger.info msg

      if index.exists?
        if !opts[:delete] and !opts[:force]
          raise RuntimeError, "The index #{index.name.inspect} already exists! Use the :force option to force loading. Use the :delete option to recreate the index."
        elsif opts[:delete]
          logger.info "Deleting old index"
          index.delete
        end
      end

      unless index.exists?
        logger.info "Creating new index"
        index.create
      end

      self
    end

    # Public: For a given database model class (an ActiveRecord class) iterate
    # over all the records in the database and load the records into the
    # ElasticSearch index. The adapter class will be used to transform the
    # database record into a document suitable for indexing in ElasticSearch.
    #
    # The database records are iterated and bulk-imported in chunks. The
    # number of records to include in each chunk is determined by the :limit
    # option. The default is 200. This limits the number of records returned
    # from the database in each iteration.
    #
    # model_class   - The class used to find database records.
    # adapter_class - An adapter class for generating indexable documents.
    # opts          - The Hash of options passed to the ActiveRecord `find` method.
    #                 :limit  - batch size for reading from the DB (default 200)
    #                 :offset - offset for reading from the DB (default 0)
    #                 :order  - the column to order by (default :id)
    #
    # Examples
    #
    #   load_model( User, Elastomer::Adapters::User )
    #   #=> Loader instance
    #
    #   load_model( Repository, Elastomer::Adapters::Repository, :limit => 500 )
    #   #=> Loader instance
    #
    # Returns this Loader instance.
    #
    def load_model( model_class, adapter_class, opts = {} )
      total = opts.delete(:total)
      opts = {
        :limit  => 200,
        :offset => 0,
        :order  => :id
      }.merge!(opts)

      running_total = 0
      adapter = adapter_class.new
      model_name = model_class.name.pluralize.underscore

      msg = "Loading #{model_name} into #{index.name.inspect}"
      $stdout.puts msg
      logger.info msg
      loop do
        models = model_class.find(:all, opts)
        break if models.empty?

        opts[:offset] += opts[:limit]
        documents = models.map do |model|
          adapter.model = model
          adapter.to_hash
        end
        documents.compact!

        $stdout.write '.'
        logger.info "Storing #{model_name} at offset #{opts[:offset]-opts[:limit]}"

        index.bulk_store(documents, :raise => false)

        if total
          running_total += opts[:limit]
          break if running_total >= total
        end
      end
      $stdout.puts
      self
    end

  end  # Loader
end  # Elastomer
