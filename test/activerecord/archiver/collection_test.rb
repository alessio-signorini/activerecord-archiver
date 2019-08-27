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

    collection = ActiveRecord::Archiver::Collection.new('JustString')
    assert_equal 'just_strings', collection.name
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
      "model"           => "Activity",
      "folder_name"     => "events",
      "track_by"        => "updated_at",
      "starting_at"     => "2019-01-01",
      "max_memory_size" => 100
    }
  end


  def id_based_collection
    {
      "model"           => "Impression",
      "folder_name"     => "impressions",
      "track_by"        => "id"
    }
  end


  def bad_config
    {
      "model"           => "Connection",
      "folder_name"     => "bad_type",
      "track_by"        => "weird_key"
    }
  end

end
