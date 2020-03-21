require 'forwardable'
require 'charge_set/charge'

module ChargeSet
  class Set
    extend Forwardable

    def_delegators :root, :charge, :total

    def initialize
      @root = Charge.new(
        guid: 'root',
        name: 'root'
      )
    end

    private

    attr_reader :root
  end
end
