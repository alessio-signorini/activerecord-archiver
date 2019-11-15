require 'active_support/core_ext/string'

module ActiveRecord; module Archiver
  class Collection


    def initialize(args)
      @args = args.is_a?(String) ? {'model' => args} : args

      validate
    end


    def find_in_json_batches(args={})
      in_json_batches(args) do |batch, max|
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


    def create_relation starting_after:nil, ending_with:nil
      relation = base_object

      if starting_after.present?
        relation = relation.where(["#{track_by} > ?", starting_after])
      end

      if ending_with.present?
        relation = relation.where(["#{track_by} <= ?", ending_with])
      end

      return relation
    end


    def last_fetched
      (Rails.cache.fetch(cache_key) || starting_at)
    end


    def batch_size
      size = @args['batch_size'].to_i
      return size > 0 ? size : 1000
    end


    def update_last_fetched(batch_max)

      if last_fetched.nil? || (!batch_max.nil? && last_fetched < batch_max)
        Rails.cache.write(cache_key, batch_max)
      end
    end


    def other_update_last_fetched(batch_max)
      last = [batch_max, last_fetched].compact.max

      Rails.cache.write(cache_key, batch_max) if last
    end

    def cache_key
      ['activerecord-archiver', rails_class.name.downcase]
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
      @rails_class ||= model.constantize
    end


    def model
      @args['model']
    end


    def item_size
      @item_size ||= base_object.last.attributes.to_json.size
    end


    def max_batch_size
      @max_batch_size ||= max_memory_size / item_size
    end


    def max_memory_size
      @args['max_memory_size'] || 50_000_000
    end


    def append(data, batch)
      data.push(*batch.map{|x| x.attributes.to_json})
    end


    def in_json_batches(args={})
      data = []
      max  = nil

      previous_stopping_point = last_fetched || base_object.minimum(track_by)
      max_for_model = base_object.maximum(track_by)

      while true do
        begin
          batch = create_relation(starting_after:previous_stopping_point, ending_with:max_for_model).order("#{track_by}").limit(batch_size).to_a
        rescue => e
          ActiveRecord::Archiver::Logger.fatal(e.message)
          raise
        end

        break if batch.empty?

        batch_max = batch.pluck(track_by).max
        previous_stopping_point = batch_max
        max = batch_max if max.nil? || batch_max > max
        data += batch.map{|x| x.attributes.to_json}

        if data.size > max_batch_size
          yield(data, max) && data.clear
        end
      end

      yield(data, max)
    end


  end
end; end
