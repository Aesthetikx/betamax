# Betamax

Betamax allows for the recording and playback of arbitrary Ruby objects to simplify testing external dependencies. Think of it like the [VCR](https://github.com/vcr/vcr) gem, but for any complicated object, not just HTTP interactions. This gem was originally developed to write a test suite for a MiniDisc NetMD Walkman library, where the recording and playback of real USB traffic was desired.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add betamax
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install betamax
```

## Usage

Currently this gem supports testing with RSpec. First, require the gem in your spec helper:

```ruby
# File: spec/spec_helper.rb

require 'betamax'
```

Then, record an object. The first time you run your test, a recording will be created in `spec/betamax_tapes/`. Subsequent test runs will playback from your recording. Make sure to tag your example as `:betamax` to enable recording and playback.

```ruby
RSpec.describe 'a MiniDisc device' do
  let(:walkman) do
    usb_device = LibUSB::Context.devices(idProduct: 0x0084).first

    MiniDisc::Device.new usb_device: Betamax.record(usb_device)
  end

  it 'has a tracklist', :betamax do
    walkman.open do |disc|
      disc.tracks.first.title.should == 'Song of the Highwire Shrimper'
    end
  end
end

```

In the above example, the test will continue to work even if the USB device is no longer present. If for some reason changes to your code change the interaction with your recorded object, your test will fail. This could be because methods were called in a different order, block arguments changed, method calls were expected but did not take place, etc.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Aesthetikx/betamax.
