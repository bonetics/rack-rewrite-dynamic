# rack-rewrite-dynamic

Rack rewrite is a great tool if you have static based rewrites. What do
you do when dynamic slug based rewrites are needed to make your SEO
seeking client happy?

Consider the following requirements:

/slug_name/another_slug_name should be rendered by /controller/id
/filter_slug-another_filter_slug-resources_name should be renderd by
/resources_name?color_ids[]=42&color_ids[]=43&category_ids[]=42

You could try to setup custom routing using
[rack-rewrite arbitraty rewriting feature](https://github.com/jtrupiano/rack-rewrite#arbitrary-rewriting).
Rack-rewrite-dynamic wraps these use cases and provides an easy way to
create your own if you need to do so.


## Installation

Add this line to your application's Gemfile:

    gem 'rack-rewrite-dynamic'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-rewrite-dynamic

## Usage

Rack-rewrite-dynamic currently assumes its beeing used as a middleware
in a rails project. The rails dependency may dissapear in the near
future, but it is required for now. It also assumes you have a Slug
model using the [friendly_id](https://github.com/norman/friendly_id) gem.

```ruby
class Slug < ActiveRecord::Base
  extend FriendlyId
  friendly_id :content, use: [:slugged, :history]
end
```

Rack-rewrite-dynamic provides two types of slug based url matchers:

### Show page URL rewrites

To set up the rewrites, hook into rack-rewrite middleware in config/application.rb

```ruby
config.middleware.insert_after "ActiveRecord::QueryCache", 'Rack::Rewrite' do |base|
  rewriter = 'Rack::Rewrite::Dynamic::Rewrites'.constantize.new do
    rewrite url_parts: [{'Category' => 'slug', 'IceCream' => 'slug'}]
  end
  rewriter.apply_rewrites(base)
end
```

The example rewrites /category_slug/ice_cream_slug to /ice_creams/42 so
the rails app can have 
```ruby
resources :ice_creams
```
defined as usual.

### Filter URL rewrites

To set up a url rewriter use

```ruby
config.middleware.insert_after "ActiveRecord::QueryCache", 'Rack::Rewrite' do |base|
  rewriter = 'Rack::Rewrite::Dynamic::Rewrites'.constantize.new do
    rewrite_filter separator: '-', target: 'cars', suffix: 'cars'
  end
  rewriter.apply_rewrites(base)
end
```

The example rewrites /color_slug-another_color_slug-category_slug-cars
to /cars?color_ids[]=42&color_ids[]=43&category_ids[]=42 so the rails
app can have
```ruby
resources :cars
```
defined as usual and use the filter attributes on the index page.

### Configuration

If you wish to use a different slug class you may pass it in as an
argument when defining the rewrite.

```ruby
config.middleware.insert_after "ActiveRecord::QueryCache", 'Rack::Rewrite' do |base|
  rewriter = 'Rack::Rewrite::Dynamic::Rewrites'.constantize.new do
    rewrite url_parts: [{'Category' => 'slug', 'IceCream' => 'slug'}],
slug_name: 'AnotherSlug'
  end
  rewriter.apply_rewrites(base)
end
```

By default the rewrites assume you have a rails application to generate
the routing. If you with to have a custom route generator, you can
supply it when defining the rewrite. It needs to respond to a
route_for(slug) message and return a string representing the url.

```ruby
class TestGenerator
  def self.route_for slug
    'some/path'
  end
end

config.middleware.insert_after "ActiveRecord::QueryCache", 'Rack::Rewrite' do |base|
  rewriter = 'Rack::Rewrite::Dynamic::Rewrites'.constantize.new do
    rewrite url_parts: [{'Category' => 'slug', 'IceCream' => 'slug'}],
route_generator_name: 'TestGenerator'
  end
  rewriter.apply_rewrites(base)
end
```






## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
