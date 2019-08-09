require "test_helper"

class ActiveRecord::ArchiverTest < Minitest::Test

  def test_that_it_has_a_version_number
    refute_nil ::ActiveRecord::Archiver::VERSION
  end


  def test_overridden_config
    ActiveRecord::Archiver.stubs(:config).returns(good_config)

    assert ActiveRecord::Archiver.config['collections'].include?('connections')
  end


  def test_archive_connections
    ActiveRecord::Archiver.stubs(:config).returns(good_config)

    x = stub_request(:put, %r!https://s3.amazonaws.com/test_bucket/first/second/connections/\d+/\d+/\d+/\d+.\d+.json.gz.gz!)
      .to_return(status: 200, body: "", headers: {})

    ActiveRecord::Archiver.archive('connections')

    assert_requested x, :times => 1
  end


  def test_archive_events
    ActiveRecord::Archiver.stubs(:config).returns(good_config)

    x = stub_request(:put, %r!https://s3.amazonaws.com/test_bucket/first/second/events/\d+/\d+/\d+/\d+.\d+.json.gz.gz!)
      .to_return(status: 200, body: "", headers: {})

    ActiveRecord::Archiver.archive('events')

    assert_requested x, :times => 7
  end


  def test_archive_badtype
    ActiveRecord::Archiver.stubs(:config).returns(config_with_sql_injection)

    assert_abort do
      ActiveRecord::Archiver.archive('bad_type')
    end
  end




  def good_config
    {
      "storage"=>{
        "type"        => "S3",
        "bucket"      => "test_bucket",
        "prefix"      => "first/second/%s",
        "path"        => "%Y/%m/%d/%s.%6N.json.gz",
        "options" => {
          "access_key_id"     => "A",
          "secret_access_key" => "B"
        }
      },
      "collections"=>[
        "connections",
        {
          "events"          => nil,
          "track_by"        => "updated_at",
          "model"           => "Activity",
          "starting_at"     => "2019-01-01",
          "max_memory_size" => 100
        }
      ]
    }
  end



  def config_with_sql_injection
    {
      "collections"=>[
        {
          "bad_type"        => nil,
          "track_by"        => "weird_key",
          "model"           => "Connection"
        }
      ]
    }
  end



end
