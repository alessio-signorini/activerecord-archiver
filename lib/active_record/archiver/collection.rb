require 'active_support/core_ext/string'

module ActiveRecord; module Archiver
  class Collection


    def initialize(args)
      @args = args.is_a?(String) ? {'model' => args} : args

      validate
    end


    def find_in_json_batches(args={})
      relation = base_object.where(clause)

      in_json_batches(relation, args) do |batch, max|
        yield(batch) && update_last_fetched(max)
      end
    end


    def name
      @args['folder_name'] || model.underscore.pluralize
    end


    private


    def validate

      unless rails_class.present?
        abort("[ActiveRecord::Archiver] Can not find any class for #{model}']}")
      end

      unless rails_class.new.respond_to?(track_by)
        abort("[ActiveRecord::Archiver] Possible SQL-injection, track_by is #{track_by} and #{model} does not have that field.")
      end
    end


    def base_object
      rails_class.respond_to?(:safe_to_archive) ? rails_class.safe_to_archive : rails_class
    end


    def clause
      last_fetched ? ["#{track_by} > ?", last_fetched] : {}
    end


    def last_fetched
      (Rails.cache.fetch(cache_key) || starting_at)
    end


    def update_last_fetched(batch_max)
      if last_fetched.nil? || batch_max > last_fetched
        Rails.cache.write(cache_key, batch_max)
      end
    end


    def cache_key
      ['activerecord-archiver', rails_class.name.downcase].join('/')
    end


    def starting_at
      time_based_tracking? ? DateTime.parse(@args['starting_at']) : @args['starting_at']
    end


    def time_based_tracking?
      @args['starting_at'] && @args['starting_at'].match(/[:\/-]/)
    end


    def track_by
      (@args['track_by'] || 'id').to_sym
    end


    def rails_class
      @rails_class ||= (model || name.downcase.camelize.singularize).constantize
    end


    def model
      @args['model']
    end


    def item_size
      @item_size ||= base_object.last.to_json.size
    end


    def max_batch_size
      @max_batch_size ||= max_memory_size / item_size
    end


    def max_memory_size
      @args['max_memory_size'] || 50000000
    end


    def append(data, batch)
      data.push(*batch.map{|x| x.to_json})
    end


    def in_json_batches(relation, args={})
      data = []
      max  = nil

      relation.find_in_batches(args) do |batch|
        batch_max = batch.pluck(track_by).max
        max = batch_max if max.nil? || batch_max > max

        data += batch.map{|x| x.to_json}

        if data.size > max_batch_size
          yield(data, max) && data.clear
        end
      end

      yield(data, max)
    end


  end
end; end
