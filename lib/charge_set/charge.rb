# frozen_string_literal: true

module ChargeSet
  class Charge
    ZERO = BigDecimal(0)

    attr_reader :guid, :name, :amount, :units, :metadata

    def initialize(guid:, name:, amount: ZERO, units: 1, metadata: {}, index: {})
      @index = index
      @guid = guid
      @name = name
      @amount = BigDecimal(amount)
      @units = units
      @metadata = metadata
      freeze
    end

    def to_args(include_charges = false)
      { guid: guid, name: name, amount: amount, units: units, metadata: metadata }.tap do |h|
        h[:index] = index if include_charges
      end
    end

    def charges
      index.values
    end

    def find(guid)
      index[guid]
    end

    def dig(*guids)
      guids = guids.clone
      ch = find(guids.shift)
      return nil unless ch
      return ch unless guids.any?
      ch.dig(*guids)
    end

    def charge(**args)
      self.class.new(**args).tap do |ch|
        index[ch.guid] = ch
      end
    end

    def remove(guid)
      index.delete guid
    end

    def total
      net_total + charges.reduce(ZERO) do |val, ch|
        val + ch.total
      end
    end

    def net_total
      amount * units
    end

    def inspect
      %(<#{self.class}##{guid} name="#{name}" total:#{total} amount:#{amount} units:#{units} #{charges.size} charges>)
    end

    private

    attr_reader :index
  end
end
