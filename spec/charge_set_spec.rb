require 'spec_helper'

RSpec.describe ChargeSet::Set do
  subject(:set) { described_class.new }

  it "has a version number" do
    expect(ChargeSet::VERSION).not_to be nil
  end

  describe '#add' do
    it 'adds charges in arbitrary dephts in tree' do
      set.add('a', name: 'Item 1', amount: 10, units: 2)
      set.add(['a', 'b'], name: 'sub', amount: -5, units: 1)
      expect(set.total).to eq 15
      ch1 = set.dig('a')
      expect(ch1.total).to eq 15
      expect(ch1.charges.size).to eq 1
      expect(set.dig('a', 'b').total).to eq -5
    end

    it 'moves existing charge from previous place in tree' do
      set.add('a', name: 'Item 1', amount: 10, units: 2)
      set.add(['a', 'ab'], name: 'sub', amount: -5, units: 1)
      # move sub-charge to a different branch
      set.add(['b', 'ab'], name: 'sub', amount: -7, units: 1)
      expect(set.total).to eq 13
      expect(set.dig('a').total).to eq 20
      expect(set.dig('b').total).to eq -7
      expect(set.dig('b', 'ab').total).to eq -7
    end

    it 'is idempotent' do
      set.add('a', name: 'Item 1', amount: 10, units: 2)
      set.add('a', name: 'Item 1', amount: 10, units: 2)

      expect(set.total).to eq 20
    end
  end

  describe '#move' do
    it 'moves charge from one branch to another, without amending data' do
      set.add('a', name: 'Item 1', amount: 10, units: 2)
      set.add(['a', 'ab'], name: 'sub', amount: -5, units: 1)
      # move sub-charge to a different branch
      moved = set.move('ab', ['foo', 'bar'])
      expect(moved.total).to eq -5
      expect(set.total).to eq 15
      set.dig('foo', 'bar', 'ab').tap do |ch|
        expect(ch.total).to eq -5
        expect(ch.guid).to eq 'ab'
        expect(ch.name).to eq 'sub'
      end
    end
  end

  describe '#remove' do
    it 'removes charge by guid' do
      set.add('a', name: 'Item 1', amount: 10, units: 2)
      set.add(['a', 'ab'], name: 'sub', amount: -5, units: 1)

      removed = set.remove('ab')
      expect(removed.total).to eq -5
      expect(set.total).to eq 20
    end

    it 'returns nil if not found' do
      expect(set.remove('nope')).to be nil
    end
  end

  describe '#amend' do
    it 'partially amends existing charge' do
      set.add(['a', 'ab'], name: 'sub', amount: 5, units: 1)
      set.amend('ab', units: 2, name: 'sub2')
      set.dig('a', 'ab').tap do |ch|
        expect(ch.total).to eq 10
        expect(ch.name).to eq 'sub2'
      end
    end
  end

  describe '#find' do
    it 'finds charge by guid, regardless of depth' do
      ch = set.add(['a', 'b', 'c'], name: 'Charge')
      expect(set.find('c')).to eq ch
    end

    it 'returns nil if not found' do
      expect(set.find('nope')).to be nil
    end
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
