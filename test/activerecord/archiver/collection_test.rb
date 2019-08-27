require "test_helper"

class ActiveRecord::Archiver::CollectionTest < Minitest::Test

  def test_initialize_with_config
    ActiveRecord::Archiver::Collection.any_instance.stubs(:validate).returns(true)

    collection = ActiveRecord::Archiver::Collection.new(good_config)
    assert_equal 'events', collection.name
    assert_equal Activity, collection.send(:rails_class)
  end

  def test_initialize_with_name
    ActiveRecord::Archiver::Collection.any_instance.stubs(:validate).returns(true)

    collection = ActiveRecord::Archiver::Collection.new('just_string')
    assert_equal 'just_string', collection.name
  end

  def test_validate_with_bad_config
    assert_abort do
      ActiveRecord::Archiver::Collection.new(bad_config)
    end
  end

  def test_validate_with_good_config
    collection = ActiveRecord::Archiver::Collection.new(good_config)
    assert collection
  end

  def test_base_object
    collection = ActiveRecord::Archiver::Collection.new(good_config)
    klass = collection.send(:base_object)

    assert_equal Activity, klass
  end

  def test_clause
    collection = ActiveRecord::Archiver::Collection.new(id_based_collection)
    klass = collection.send(:clause)

    assert klass.is_a?(Hash)
    assert klass.empty?
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
      "impressions"     => nil,
      "track_by"        => "id",
      "model"           => "Impression"
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
