require 'spec_helper'

RSpec.describe ChargeSet::Charge do
  specify 'Charge' do
    ch = described_class.new(guid: 'a', name: 'A', amount: 1000, units: 2)
    expect(ch.total.to_f).to eq(20.0)
    expect(ch.net_total.to_f).to eq(20.0)

    ch.charge(guid: 'b', name: 'B', amount: -200)
    expect(ch.charges.size).to eq(1)
    expect(ch.total.to_f).to eq(18.0)
    expect(ch.net_total.to_f).to eq(20.0)
    expect(ch.find('b').total.to_f).to eq(-2.0)
    expect(ch.find('anana')).to be nil
  end
end
