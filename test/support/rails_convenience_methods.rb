class String
  def camelize
    self.capitalize
  end

  def singularize
    self.chop
  end

  def constantize
    eval("::#{self}")
  end
end


class Hash
  def deep_symbolize_keys
    map{|k,v| [k.to_sym, v.is_a?(Hash) ? v.deep_symbolize_keys : v]}.to_h
  end
end

class Object
  def present?
    self.class != NilClass
  end
end


module Rails
  def self.cache
    @cache ||= RailsCache.new
  end
end


class RailsCache
  @@memory = {}

  def fetch(key)
    @@memory[key]
  end

  def write(key,value)
    @@memory[key] = value
  end
end