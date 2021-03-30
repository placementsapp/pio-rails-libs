# PioRailsLibs

This is not a typical gem, it's intended as an internal code sharing mechanism and is not well encapsulated. Please don't release into rubygems.org

It contains some common code for our Rails based apps.

Most classes are not under `PioRailsLibs` namespace due to historical reasons. But we can provide a migration path later.

It also has implicit dependency on Rails and some environment variables.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pio_rails_libs'
```

And then execute:

    $ bundle install

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

**Don't DO THIS**: To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pio_rails_libs.


## License

The gem is not licensed to be used outside.
