require "test_helper"

class ActiveRecord::ArchiverTest < Minitest::Test

  def test_that_it_has_a_version_number
    refute_nil ::ActiveRecord::Archiver::VERSION
  end

  def test_overridden_config
    ActiveRecord::Archiver.stubs(:config).returns(good_config)

    assert ActiveRecord::Archiver.config['models'].any?{ |s| s["model"] == ('Connection') }
  end

  def test_archive_connections
    ActiveRecord::Archiver.stubs(:config).returns(good_config)

    s3_request = stub_request(:put, %r!s3.*/connections/\d+/\d+/\d+/\d+.\d+.json.gz!)
      .to_return(status: 200, body: "", headers: {})

    ActiveRecord::Archiver.archive('connections')

    assert_requested s3_request, :times => 1
  end

  def test_archive_events
    ActiveRecord::Archiver.stubs(:config).returns(good_config)

    s3_request = stub_request(:put, %r!s3.*/events/\d+/\d+/\d+/\d+.\d+.json.gz!)
      .to_return(status: 200, body: "", headers: {})

    ActiveRecord::Archiver.archive('events')

    assert_requested s3_request, :times => 2
  end

  def test_archive_badtype
    ActiveRecord::Archiver.stubs(:config).returns(config_with_sql_injection)

    assert_abort do
      ActiveRecord::Archiver.archive('Connection')
    end
  end

  def test_run_it_twice
    ActiveRecord::Archiver.stubs(:config).returns(good_config)

    s3_request = stub_request(:put, %r!s3.*/events/\d+/\d+/\d+/\d+.\d+.json.gz!)
      .to_return(status: 200, body: "", headers: {})

    ActiveRecord::Archiver.archive('events')
    assert_requested s3_request, :times => 2

    ActiveRecord::Archiver.archive('events')
    ActiveRecord::Archiver.archive('events')
    ActiveRecord::Archiver.archive('events')
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
          "secret_access_key" => "B",
          "region"            => "us-east-1"
        }
      },
      "models"=>[
        {
          "model"           => "Connection"
        },
        {
          "model"           => "Activity",
          "folder_name"     => "events",
          "track_by"        => "updated_at",
          "starting_at"     => "2019-01-01",
          "max_memory_size" => 100
        }
      ]
    }
  end



  def config_with_sql_injection
    {
      "models"=>[
        {
          "model"           => "Connection",
          "folder_name"     => "bad_type",
          "track_by"        => "weird_key"
        }
      ]
    }
  end



end
