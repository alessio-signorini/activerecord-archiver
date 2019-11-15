require 'aws-sdk-s3'

module ActiveRecord; module Archiver; module Store
  class S3


    def initialize(args)
      @bucket   = args.fetch('bucket')
      @prefix   = args.fetch('prefix', nil)
      @path     = args.fetch('path', '%Y/%m/%d/%s.%6N.json.gz')
      @options  = args.fetch('options', {})

      @client = create_client
    end


    def write(batch, subpath=nil)
      path = make_path(subpath)
      data = format(batch)

      response = send_data(@bucket, path, data)

      return response.successful?
    end


    def format(data)
      data.join("\n")
    end


    def make_path(string=nil)
      prefix = @prefix % string
      full_path = File.join(prefix, @path)
      return Time.now.strftime(full_path)
    end

  private

    def create_client
      Aws::S3::Client.new(@options.deep_symbolize_keys)
    end

    def send_data(bucket, path, data)
      ActiveRecord::Archiver::Logger.info("Saving '#{path}' to S3 bucket '#{bucket}' (#{data.size} bytes)")
      @client.put_object({
        server_side_encryption: 'aws:kms',
        content_type:           'application/jsonl',
        content_encoding:       'gzip',

        bucket: bucket,
        key:    path,
        body:   Zlib.gzip(data)
      })
    end
  end
end; end; end
