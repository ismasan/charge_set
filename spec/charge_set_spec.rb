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

    set.charge(guid: 'bca', name: 'Item 2', amount: 15, units: 1)

    expect(set.total).to eq 35
    expect(set.charges.size).to eq 2
    expect(set.units).to eq 3

    # replace
    set.charge(guid: 'abc', name: 'Item 1', amount: 10, units: 1)

    expect(set.total).to eq 25
    expect(set.charges.size).to eq 2
    expect(set.units).to eq 2
  end

  it 'adds charges to charges in set' do
    set.charge(guid: 'abc', name: 'Item 1', amount: 10, units: 2)
    ch1a = set.charge_item('abc', guid: 'sub1', name: 'sub', amount: -5, units: 1)
    expect(set.total).to eq 15
    ch1 = set.find('abc')
    expect(ch1.total).to eq 15
    expect(ch1.charges.size).to eq 1

    # Amend charge. Sub-charges are preserved.
    ch1 = set.amend_item('abc', name: 'Item 1', amount: 10, units: 1)
    expect(ch1.total).to eq 5
    expect(ch1.charges.size).to eq 1

    # Replace charge. Any sub-charges need to be added again
    ch1 = set.charge(guid: 'abc', name: 'Item 1', amount: 10, units: 1)
    expect(ch1.total).to eq 10
    expect(ch1.charges.size).to eq 0
  end

  it 'adds meta data to charges' do
    ch1 = set.charge(guid: 'ch1', name: 'Item 1', amount: 10, metadata: {foo: 'bar'})
    expect(ch1.metadata[:foo]).to eq 'bar'
  end

  describe '#dig' do
    it 'locates sub charge' do
      ch1 = set.charge(guid: 'ch1', name: 'Item 1', amount: 10, units: 2)
      ch1a = ch1.charge(guid: 'ch1.a', name: 'Sub', amount: 4)
      ch1aa = ch1a.charge(guid: 'ch1.a.a', name: 'Sub 2', amount: 2)

      expect(set.dig('ch1', 'ch1.a', 'ch1.a.a')).to eq ch1aa
      expect(set.dig('ch1', 'ch1.a', 'ch1.a.a', 'foo')).to be nil
    end
  end
end
