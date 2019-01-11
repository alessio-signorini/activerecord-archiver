require 'aws-sdk-s3'

module ActiveRecord::Archiver::Store
  class S3


    def initialize(args)
      @bucket   = args.fetch('bucket')
      @prefix   = args.fetch('prefix', nil)
      @path     = args.fetch('path', '%Y/%m/%d/%s.%6N.json.gz')
      @options  = args.fetch('options', {})

      @client = Aws::S3::Client.new(@options.deep_symbolize_keys)
    end


    def write(batch, subpath=nil)
      path = make_path(subpath)
      data = format(batch)

      response = @client.put_object({
        server_side_encryption: 'aws:kms',
        content_type:           'application/json',
        content_encoding:       'gzip',

        bucket: @bucket,
        key:    path,
        body:   Zlib.gzip(data)
      })

      return response.success?
    end


    def format(data)
      data.map{|x| x.to_json}.join("\n")
    end


    def make_path(string=nil)
      prefix = @prefix && string ? @prefix.gsub('%s', string) : @prefix
      full_path = [prefix, @path].compact.join('/')
      return Time.now.strftime(full_path)
    end


  end
end
