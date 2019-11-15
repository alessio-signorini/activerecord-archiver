require_relative 'archiver/collection'
require_relative 'archiver/store/s3'
require_relative 'archiver/version'
require_relative 'archiver/logger'

module ActiveRecord
  module Archiver


    def self.config
      @config ||= YAML.load(ERB.new(config_file.read).result)

    rescue
      message = 'config/archiver.yml not found or contains errors'
      ActiveRecord::Archiver::Logger.info(message)
      abort("[ActiveRecord::Archiver] #{message}")
    end


    def self.store
      @store ||= store_class.new(config['storage'])
    end


    def self.archive(only=nil, logger:nil)
      ActiveRecord::Archiver::Logger.init(logger)
      ActiveRecord::Archiver::Logger.info("Archiving started")

      specified_collections = Array(only)
      collections.select{|x| only.nil? || specified_collections.include?(x.name)}.each do |collection|

        ActiveRecord::Archiver::Logger.info("Archiving #{collection.name}")
        collection.find_in_json_batches() do |json_array|
          store.write(json_array, collection.name)
        end
        ActiveRecord::Archiver::Logger.info("Done archiving #{collection.name}")
      end

      ActiveRecord::Archiver::Logger.info("Archiving complete")
    end


    private


    def self.config_file
      Rails.root.join('config', 'archiver.yml')
    end


    def self.store_class
      ('ActiveRecord::Archiver::Store::' + config['storage']['type']).constantize
    end


    def self.collections
      config['models'].map do |args|
        Collection.new(args)
      end
    end

  end
end
