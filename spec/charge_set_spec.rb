require 'spec_helper'

RSpec.describe ChargeSet::Set do
  subject(:set) { described_class.new }

  it "has a version number" do
    expect(ChargeSet::VERSION).not_to be nil
  end

  it 'adds charges to set' do
    ch1 = set.charge(guid: 'abc', name: 'Item 1', amount: 10, units: 2)
    expect(ch1.total).to eq 20
    expect(ch1.amount).to eq 10
    expect(ch1.units).to eq 2

    expect(set.total).to eq 20

    ch2 = set.charge(guid: 'bca', name: 'Item 2', amount: 15, units: 1)

    expect(set.total).to eq 35
  end

  it 'adds charges to charges in set' do

  end
end
