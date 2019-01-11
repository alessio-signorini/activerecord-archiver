require "erb"

module ActiveRecord
  module Archiver


    def self.config
      @config ||= YAML.load(ERB.new(config_file.read).result)

      rescue
        abort('[ActiveRecord::Archiver] config/archiver.yml not found or contains errors')
    end


    def self.store
      @store ||= store_class.new(config['storage'])
    end


    def self.archive
      collections.each do |collection|
        collection.find_in_batches do |batch|
          store.write(batch, collection.name)
        end
      end
    end


    private


    def self.config_file
      Rails.root.join('config', 'archiver.yml')
    end


    def self.store_class
      ('ActiveRecord::Archiver::Store::' + config['storage']['type']).constantize
    end


    def self.collections
      config['collections'].map do |args|
        Collection.new(args)
      end
    end

  end
end
