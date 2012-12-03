require_relative '../../../../lib/rack/rewrite/dynamic/rewrites'

describe Rack::Rewrite::Dynamic::Rewrites do

  it 'adds a rewrite' do
    subject.rewrite
    subject.rewrites.size.should > 0
  end
  it 'adds a rewrite_filter' do
    subject.rewrite_filter
    subject.rewrites.size.should > 0
  end

  it 'applies rewrites' do
    base = stub

    subject.rewrite
    subject.rewrites.each {|rewrite| rewrite.should_receive(:apply_rewrite).with(base) }
    subject.apply_rewrites(base)
  end

end
