require "test_helper"

class ActiveRecord::Archiver::Store::S3::MakePathTest < Minitest::Test

  def setup
    super

    ActiveRecord::Archiver::Store::S3.any_instance.stubs(:create_client)
    args = {
      'bucket'  => 'secchio',
      'prefix'  => '/prefisso/%s'
    }

    @s3 = ActiveRecord::Archiver::Store::S3.new(args)
  end

  def test_without_extra_string
    path = @s3.make_path

    assert_match /\/prefisso\/\d+\/\d+\/\d+\/\d+.\d+.json.gz/, path
  end

  def test_with_extra_string

    path = @s3.make_path 'bark'

    assert_match /\/prefisso\/bark\/\d+\/\d+\/\d+\/\d+.\d+.json.gz/, path
  end

end