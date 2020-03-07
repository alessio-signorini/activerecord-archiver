require "test_helper"

class ActiveRecord::Archiver::Store::S3::WriteTest < Minitest::Test

  def setup
    super

    ActiveRecord::Archiver::Store::S3.any_instance.stubs(:create_client)

    args = {
      'bucket'  => 'secchio'
    }

    @s3 = ActiveRecord::Archiver::Store::S3.new(args)
  end

  def test_write_without_subpath

    full_path = 'percorso/completo/'
    data = "some data"

    @s3.stubs(:make_path).with(nil).returns(full_path)
    @s3.stubs(:format).with(data).returns(data)

    response = stub(:successful? => true)
    @s3.stubs(:send_data).with('secchio', full_path, data).returns(response)

    @s3.write(data)
  end

  def test_write_with_subpath

    sub_path = 'sottotracciato'
    full_path = File.join('percorso/completo/', sub_path)
    data = "some data"

    @s3.stubs(:make_path).with(sub_path).returns(full_path)
    @s3.stubs(:format).with(data).returns(data)

    response = stub(:successful? => true)
    @s3.stubs(:send_data).with('secchio', full_path, data).returns(response)

    @s3.write(data, sub_path)
  end


  def test_write_with_no_data

    sub_path = 'sottotracciato'
    full_path = File.join('percorso/completo/', sub_path)
    data = "some data"

    @s3.stubs(:make_path).with(sub_path).returns(full_path)
    @s3.stubs(:format).with(data).returns(data)

    response = stub(:successful? => true)
    @s3.stubs(:send_data).with('secchio', full_path, data).returns(response)

    @s3.write(data, sub_path)
  end
end