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

  let(:base) { mock(:base) }
  let(:rack_env) { { 'REQUEST_URI' => 'some/path' } }

  let(:opts) { {} }
  subject { Rack::Rewrite::Dynamic::FilterRewrite.new(opts) }
  its(:opts) { should eq(opts) }

  it 'should return the original request if assets' do
    match = ['', 'assets']
    subject.perform(match, rack_env).should eq('some/path')
  end

  context 'handle SEO urls like /slug1-slug2-outfits/red-green-colored-from-nike-and-red-mountain' do
    let(:opts) do
      {
        target: 'outfits',
        url_parts: [{suffix: 'outfits', separator: '-'},
                    {
                      groups: [
                                {suffix: '-colored', separator: '-'},
                                {prefix: 'from-', separator: '-and-'}
                              ]
                    }
                   ]
      }
    end
    let(:match) { ['', 'business-', 'red-darkblue', 'nike-and-red-mountain'] }

    it 'should apply rewrite' do
      base.should_receive(:rewrite).with do |*args|
        !args.first.match("/slug1-slug2-outfits/red-green-colored-from-nike-and-red-mountain").nil?
      end
      subject.apply_rewrite(base)
    end

    it 'should perform rewrite' do
      subject.stub(:find_sluggable).with('business'){ { sluggable_type: 'outfit_category', sluggable_id: 42 } }
      subject.stub(:find_sluggable).with('red'){ { sluggable_type: 'color', sluggable_id: 42 } }
      subject.stub(:find_sluggable).with('darkblue'){ { sluggable_type: 'color', sluggable_id: 43 } }
      subject.stub(:find_sluggable).with('nike'){ { sluggable_type: 'brand', sluggable_id: 42 } }
      subject.stub(:find_sluggable).with('red-mountain'){ { sluggable_type: 'brand', sluggable_id: 43 } }

      subject.perform(match, rack_env).should eq('/outfits?brand_ids%5B%5D=42&brand_ids%5B%5D=43&color_ids%5B%5D=42&color_ids%5B%5D=43&outfit_category_ids%5B%5D=42')
    end

    it 'should not return path if slug wasn not found' do
      subject.stub(:find_sluggable)
      subject.perform(match, rack_env).should eq('some/path')
    end
  end

  context 'handle SEO urls like /fashion-items/slug1-slug2/red-green-colored-from-nike-or-red-mountain' do
    let(:opts) do
      {
        target: 'products',
        url_parts: [{static: 'fashion-items'},
                    {suffix: '', separator: '-'},
                    {
                      groups: [
                        {suffix: '-colored', separator: '-'},
                        {prefix: 'from-', separator: '-or-'}
                      ]
                    }
                   ]
      }
    end
    let(:match) { ['', 'tops-shirts', 'blue-red-darkgray', 'nike-or-adidas'] }

    before :each do
      subject.stub(:find_sluggable).with('tops-shirts'){ { sluggable_type: 'product_category', sluggable_id: 42 } }
      subject.stub(:find_sluggable).with('blue'){ { sluggable_type: 'color', sluggable_id: 42 } }
      subject.stub(:find_sluggable).with('red'){ { sluggable_type: 'color', sluggable_id: 43 } }
      subject.stub(:find_sluggable).with('darkgray'){ { sluggable_type: 'color', sluggable_id: 44 } }
      subject.stub(:find_sluggable).with('nike'){ { sluggable_type: 'brand', sluggable_id: 42 } }
      subject.stub(:find_sluggable).with('adidas'){ { sluggable_type: 'brand', sluggable_id: 43 } }
    end

    it 'should apply rewrite' do
      base.should_receive(:rewrite).with do |*args|
        !args.first.match("/fashion-items/slug1-slug2/red-green-colored-from-nike-or-red-mountain").nil?
      end
      subject.apply_rewrite(base)
    end

    it 'should perform the rewrite' do
      subject.perform(match, rack_env).should eq('/products?brand_ids%5B%5D=42&brand_ids%5B%5D=43&color_ids%5B%5D=42&color_ids%5B%5D=43&color_ids%5B%5D=44&product_category_ids%5B%5D=42')
    end

    it 'should perform the rewrite even if some of the slug groups are missing' do
      match = ['', 'tops-shirts', 'blue-red-darkgray']

      subject.perform(match, rack_env).should eq('/products?color_ids%5B%5D=42&color_ids%5B%5D=43&color_ids%5B%5D=44&product_category_ids%5B%5D=42')
    end


  end
end

