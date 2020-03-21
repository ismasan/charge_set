require 'forwardable'
require 'charge_set/charge'

module ChargeSet
  class Set
    extend Forwardable

    def_delegators :root, :charge, :charges, :total, :find, :dig

    def initialize
      @root = Charge.new(
        guid: 'root',
        name: 'root'
      )
    end

    def units
      root.charges.sum &:units
    end

    def charge_item(guid, **args)
      ch = root.find(guid)
      return false unless ch

      ch.charge(args)
    end

    def amend_item(guid, **args)
      ch = root.find(guid)
      return false unless ch

      ch.amend(args)
    end


    private

    attr_reader :root
  end
end
