require_relative '../../../lib/rack/rewrite/dynamic/rewrites'

require 'rack'
require 'rack-rewrite'

class Slug
  def self.create!(attrs)
    @attrs = attrs
  end
  def self.find(slug)
    @attrs
  end
end

class TestSlug
  def self.create!(attrs)
    @attrs = attrs
  end
  def self.find(slug)
    @attrs
  end
end


class TestGenerator
  def self.route_for slug, opts
    'some/path'
  end
end

describe Rack::Rewrite::Dynamic do

  let(:app) { mock(:app)}
  let(:env) { { 'PATH_INFO' => '/online-shops/murdar'} }
  before :each do
    Slug.create!(sluggable_type: 'Merchant', sluggable_id: 42, content: 'Murdar')
  end

  it 'uses dynamic rewrites' do
    Rack::Rewrite::Dynamic::Rewrite.any_instance.stub(:slug_path_if_present) { '/merchants/42' }
    subject = Rack::Rewrite.new(app) do |base|
      Rack::Rewrite::Dynamic::Rewrites.new(base) do
        rewrite url_parts: [{'online-shops' => 'static', 'Merchant' => 'slug'}]
      end
    end
    app.should_receive(:call).with({"PATH_INFO"=>"/merchants/42", "REQUEST_URI"=>"/merchants/42", "QUERY_STRING"=>""})
    subject.call(env)
  end

  it 'accepts a different route generator' do
    subject = Rack::Rewrite.new(app) do |base|
      Rack::Rewrite::Dynamic::Rewrites.new(base) do
        rewrite url_parts: [{'online-shops' => 'static', 'Merchant' => 'slug'}], route_generator_name: 'TestGenerator'
      end
    end
    app.should_receive(:call).with({"PATH_INFO"=>"some/path", "REQUEST_URI"=>"some/path", "QUERY_STRING"=>""})
    subject.call(env)
  end

  it 'accepts a different slug class' do
    TestSlug.create!(sluggable_type: 'Merchant', sluggable_id: 42, content: 'Murdar')
    Rack::Rewrite::Dynamic::Rewrite.any_instance.stub(:slug_path_if_present) { '/merchants/42' }
    subject = Rack::Rewrite.new(app) do |base|
      Rack::Rewrite::Dynamic::Rewrites.new(base) do
        rewrite url_parts: [{'online-shops' => 'static', 'Merchant' => 'slug'}], slug_name: 'TestSlug'
      end
    end
    app.should_receive(:call).with({"PATH_INFO"=>"/merchants/42", "REQUEST_URI"=>"/merchants/42", "QUERY_STRING"=>""})
    subject.call(env)
  end


end
