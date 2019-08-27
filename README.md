# ActiveRecord::Archiver

**Easy to use gem to archive ActiveRecord objects to permanent storage.**

With the proliferation of data science and data platforms there is a growing
need to move data that was historically kept in siloed database into a single
common storage where analysis can then be performed. This gem tries to help
with that task, requiring as little configuration as possible.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-archiver'
```

and then execute:

    $ bundle install

Or install it yourself as:

    $ gem install activerecord-archiver

## Configuration

Create a `config/archiver.yml` file with a configuration similar to the
following:
```yaml
storage:
  type: S3
  bucket: test_bucket
  prefix: 'first/second/%s'
  path: '%Y/%m/%d/%s.%6N.json.gz'
  options:
    access_key_id: 'A'
    secret_access_key: 'B'

models:
  - model: ClassA
  - model: ClassB
    folder_name: a_folder_named_b
    track_by: updated_at
    starting_at: '2019-01-01'
  - model: ClassC
    starting_at: '2010-06-05'
  - model: ClassD
```

#### Storage
The only storage type supported at the moment is Amazon **`S3`**. Items will be
converted to JSON, saved into separated lines, and GZIP-ed. Here are some
configuration instructions:
* `bucket` (**required**) - the bucket into which to write
* `prefix` (optional) - this string will be prefixed to the final path of each
  file created. If it contains `%s` it will be substituted with the name of
  the collection (e.g., `connections` or `events`).
* `path` (optional) - this string will be passed to `Time.now.strftime` and the
  results will be appended to the path. By default it is `%Y/%m/%d/%s.%6N.json`.
* `option` (optional) - anything added there will be used as-is in the
initialization of the `AWS::S3::Client`. You are encouraged to look at the
[official documentation](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method)
to learn how to correctly configure the credentials (e.g., `options` can be
omitted if you have AWS credentials setup in `ENV`).

#### Models
Each entry in `models` represent a model to archive. Default options will be used for
any keys that are missing (besides `model` which is required).
(e.g., `folder_name` will be a pluralized and snake_cased version of the `model`) or each entry can be configured with:
* `model`(**required**) - if the entry name does not represent the class you can use this
  option to specify the real class name
* `folder_name` (optional) - the name of the sub-folder (after the `prefix`) where the data
  will be written
* `track_by` (optional) - the key to use as iteration, by default it is `id` but anything
  incremental will do (e.g., `updated_at`)
* `starting_at` (optional) - if you do not want to start from the beginning, specify here
  the value of `track_by` to start from (e.g., `12345` or `2019-01-01`)
* `max_memory_size` (optional) - maximum number of bytes per file

## Usage

Once the configuration file is in place and the gem is required running

    ActiveRecord::Archiver.archive

is all you need. If you prefer to only archive one collection, pass its name
as parameter, e.g.,

    ActiveRecord::Archiver.archive('events')

It is recommended running it in a background thread (e.g.,
[Sidekiq](https://github.com/mperham/sidekiq) or
[ActiveJob](https://guides.rubyonrails.org/active_job_basics.html)). Since it
performs lots of `.to_json` operations it is also recommended to use a fast
JSON encoder/decoder (e.g., [OJ](https://github.com/ohler55/oj))

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake test` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file
to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
```
https://github.com/alessio-signorini/activerecord-archiver
```
This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of
the [MIT License](https://opensource.org/licenses/MIT).