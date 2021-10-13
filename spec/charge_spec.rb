require 'spec_helper'

RSpec.describe ChargeSet::Charge do
  specify 'Charge' do
    ch = described_class.new(guid: 'a', name: 'A', amount: 10, units: 2)
    expect(ch.total).to eq(20)
    expect(ch.net_total).to eq(20)

    ch.charge(guid: 'b', name: 'B', amount: -2)
    expect(ch.charges.size).to eq(1)
    expect(ch.total).to eq(18)
    expect(ch.net_total).to eq(20)
    expect(ch.find('b').total).to eq(-2)
    expect(ch.find('anana')).to be nil
  end
end
