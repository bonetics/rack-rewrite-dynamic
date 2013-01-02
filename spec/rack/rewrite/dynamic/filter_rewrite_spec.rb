require_relative '../../../../lib/rack/rewrite/dynamic/filter_rewrite'

describe Rack::Rewrite::Dynamic::FilterRewrite do

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
      target: 'outfits',
      url_parts: [{suffix: '-outfits'},
                  {
                    groups: [
                              {suffix: '-colored-', separator: '-'},
                              {prefix: 'from-', separator: '-and-'}
                            ]
                  }
                 ]
    }
  end
  subject { Rack::Rewrite::Dynamic::FilterRewrite.new(opts) }
  let(:base) { mock(:base) }

  its(:opts) { should eq(opts) }

  it 'should apply rewrite' do
    base.should_receive(:rewrite).with(/^\/([^\/]+)-outfits\/([^\/]+)/, anything)
    subject.apply_rewrite(base)
  end

  describe '#perform' do
    let(:match) { ['', 'business', 'red-darkblue-colored-from-nike-and-red-mountain'] }
    let(:rack_env) { { 'REQUEST_URI' => 'some/path' } }
    it 'should perform rewrite' do
      subject.stub(:find_sluggable).with('business'){ { sluggable_type: 'outfit_category', sluggable_id: 42 } }
      subject.stub(:find_sluggable).with('red'){ { sluggable_type: 'color', sluggable_id: 42 } }
      subject.stub(:find_sluggable).with('darkblue'){ { sluggable_type: 'color', sluggable_id: 43 } }
      subject.stub(:find_sluggable).with('nike'){ { sluggable_type: 'brand', sluggable_id: 42 } }
      subject.stub(:find_sluggable).with('red-mountain'){ { sluggable_type: 'brand', sluggable_id: 43 } }

      subject.perform(match, rack_env).should eq('/outfits?brand_ids%5B%5D=42&brand_ids%5B%5D=43&color_ids%5B%5D=42&color_ids%5B%5D=43&outfit_category_ids%5B%5D=42')
    end

    it 'should return the original request if assets' do
      match[1] = 'assets'
      subject.perform(match, rack_env).should eq('some/path')
    end

    it 'should not return path if slug wasn not found' do
      subject.stub(:find_sluggable)
      subject.perform(match, rack_env).should be_nil
    end

  end

end

