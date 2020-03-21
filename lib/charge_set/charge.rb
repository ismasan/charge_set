module ChargeSet
  class Charge
    attr_reader :guid, :name, :amount, :units, :category, :metadata

    def initialize(guid:, name:, amount: 0, units: 1, category: :pricing, metadata: {})
      @index = {}
      @guid = guid
      @name = name
      @amount = amount
      @units = units
      @category = category
      @metadata = metadata
    end

    def charges
      index.values
    end

    def find(guid)
      index[guid]
    end

    def dig(*guids)
      guid = guids.shift
      ch = find(guid)
      return nil unless ch
      return ch unless guids.any?
      ch.dig(*guids)
    end

    def amend(name: nil, amount: nil, units: nil, category: nil)
      @name = name if name
      @amount = amount if amount
      @units = units if units
      @category = category if category
      self
    end

    def charge(**args)
      self.class.new(args).tap do |ch|
        index[ch.guid] = ch
      end
    end

    def total
      net_total + charges.reduce(0) do |val, ch|
        val + ch.total
      end
    end

    def net_total
      amount * units
    end

    private

    attr_reader :index
  end
end
