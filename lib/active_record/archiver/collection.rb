module ActiveRecord::Archiver
  class Collection


    def initialize(args)
      @args = args.is_a?(String) ? {'name' => args} : args

      validate
    end


    def find_in_batches(args={})
      base_object.where(clause).find_in_batches(args) do |batch|
        yield(batch) && update_last_fetched(batch)
      end
    end


    def name
      @args['name'] || @args.keys.first
    end


    private


    def validate
      unless rails_class.present?
        abort("[ActiveRecord::Archiver] Can not find any class for #{model||name}']}")
      end

      unless rails_class.new.respond_to?(track_by)
        abort("[ActiveRecord::Archiver] Possible SQL-injection, track_by is #{track_by}")
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


    def update_last_fetched(batch)
      batch_max = batch.pluck(track_by).max

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

  end
end
