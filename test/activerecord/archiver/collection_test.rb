require "test_helper"

class ActiveRecord::Archiver::CollectionTest < Minitest::Test

  def test_initialize
    ActiveRecord::Archiver::Collection.any_instance.stubs(:validate).returns(true)

    a = ActiveRecord::Archiver::Collection.new(good_config)
      assert_equal 'events', a.name
      assert_equal Activity, a.send(:rails_class)

    c = ActiveRecord::Archiver::Collection.new('just_string')
      assert_equal 'just_string', c.name
  end


  def test_validate
    assert_abort do
      ActiveRecord::Archiver::Collection.new(bad_config)
    end

    a = ActiveRecord::Archiver::Collection.new(good_config)
      assert a
  end


  def test_base_object
    a = ActiveRecord::Archiver::Collection.new(good_config)
    c = a.send(:base_object)

    assert_equal Activity, c
  end


  def test_clause
    a = ActiveRecord::Archiver::Collection.new(id_based_collection)
    puts 'A'
    c = a.send(:clause)

    assert c.is_a?(Hash)
    assert c.empty?
  end



  def good_config
    {
      "events"          => nil,
      "track_by"        => "updated_at",
      "model"           => "Activity",
      "starting_at"     => "2019-01-01",
      "max_memory_size" => 100
    }
  end


  def id_based_collection
    {
      "events"          => nil,
      "track_by"        => "id",
      "model"           => "Activity"
    }
  end


  def bad_config
    {
      "bad_type"        => nil,
      "track_by"        => "weird_key",
      "model"           => "Connection"
    }
  end

end
