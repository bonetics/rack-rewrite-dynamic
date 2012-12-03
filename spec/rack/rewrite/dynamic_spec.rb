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

describe Rack::Rewrite::Dynamic do

  let(:app) { mock(:app)}
  it 'uses dynamic rewrites' do
    Rack::Rewrite::Dynamic::Rewrite.any_instance.stub(:slug_path_if_present) { '/merchants/42' }
    Slug.create!(sluggable_type: 'Merchant', sluggable_id: 42, content: 'Murdar')

    env = { 'PATH_INFO' => '/online-shops/murdar'}
    subject = Rack::Rewrite.new(app) do |base|
      rewriter = Rack::Rewrite::Dynamic::Rewrites.new do
        rewrite url_parts: [{'online-shops' => 'static', 'Merchant' => 'slug'}]
      end
      rewriter.apply_rewrites(base)
    end
    app.should_receive(:call).with({"PATH_INFO"=>"/merchants/42", "REQUEST_URI"=>"/merchants/42", "QUERY_STRING"=>""})
    subject.call(env)
  end

end
