module ChargeSet
  class Charge
    attr_reader :guid, :name, :amount, :units, :category

    def initialize(guid:, name:, amount: 0, units: 1, category: :pricing)
      @charges = {}
      @guid = guid
      @name = name
      @amount = amount
      @units = units
      @category = category
    end

    def charge(**args)
      self.class.new(args).tap do |ch|
        charges[ch.guid] = ch
      end
    end

    def total
      net_total + charges.values.reduce(0) do |val, ch|
        val + ch.total
      end
    end

    def net_total
      amount * units
    end

    private

    attr_reader :charges
  end
end
