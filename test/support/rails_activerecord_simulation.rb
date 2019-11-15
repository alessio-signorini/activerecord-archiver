class FakeActiveRecord

  def self.where(clause)
    self
  end

  def self.find_in_batches(args)
    data.each do |d|
      yield FakeActiveRelation.new(d)
    end
  end

  def self.data(n=5)
    (0..n*5).map{|i| item(i)}.each_slice(n)
  end

  def self.item(id)
    OpenStruct.new(
      :id           => id,
      :var          => rand(id),
      :updated_at   => DateTime.parse('2018-01-01T00:00:00') + (id*60)
    )
  end

  def self.last
    item(9999)
  end

  def self.order args
    return self
  end

  def self.limit args
    return self
  end

  def self.minimum column_name
    item(1)[:updated_at]
  end

  def self.maximum column_name
    item(9999)[:updated_at]
  end

  def self.to_a
    return []
  end

end

class Connection < FakeActiveRecord
  def id

  end
end

class Activity < FakeActiveRecord
  def updated_at

  end
end

class Impression < FakeActiveRecord
  def id

  end
end

class FakeActiveRelation < Array
  def pluck(key)
    self.map{|x| x.send(key)}
  end
end
