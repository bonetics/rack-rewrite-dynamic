require_relative '../../../../lib/rack/rewrite/dynamic/rewrite'

describe Rack::Rewrite::Dynamic::Rewrite do
  before(:each) do
    unless defined?(ActiveRecord::RecordNotFound)
      module ActiveRecord
        module RecordNotFound; end
      end
    end
    unless defined?(Slug)
      class Slug; end
    end
  end

  let(:opts) do
    {
      url_parts: [{'online-shops' => 'static',
                  'Merchant' => 'slug'}]
    }
  end
  subject { Rack::Rewrite::Dynamic::Rewrite.new(opts) }
  let(:base) { mock(:base) }

  its(:opts) { should eq(opts) }

  it 'should apply rewrite' do
    base.should_receive(:rewrite)
    subject.apply_rewrite(base)
  end

  describe '#perform' do
    let(:match) { ['', 'merchant-slug'] }
    let(:rack_env) { { 'REQUEST_URI' => 'some/path' } }

    it 'should return the original request if assets' do
      match[1] = 'assets'
      subject.perform(match, rack_env).should eq('some/path')
    end

    it 'should parse the url_parts and return first match' do
      subject.stub(:find_urls) { ['some/path', 'some_other/path'] }
      subject.perform(match, rack_env).should eq('some/path')
    end

    it 'should find urls' do
      subject.stub(:find_url) { 'some/path' }
      subject.find_urls(match, rack_env).should == ['some/path']
    end

    it 'should find url' do
      subject.stub(:slug_type?) { stub }
      subject.stub(:slug_path_if_present) { 'some/path' }
      subject.find_url(opts[:url_parts].first, match, rack_env).should eq('some/path')
    end

    it 'should not return path if slug wasn not found' do
      subject.stub(:slug_type?) { stub }
      subject.stub(:slug_path_if_present)
      subject.find_url(opts[:url_parts].first, match, rack_env).should be_nil
    end
  end
end
