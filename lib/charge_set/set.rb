require 'forwardable'
require 'charge_set/charge'

module ChargeSet
  class Set
    extend Forwardable

    def_delegators :root, :charge, :charges, :total, :dig

    def initialize
      @root = Charge.new(
        guid: 'root',
        name: 'root'
      )
      @index = {}
    end

    def add(path, **args)
      path = Array(path)
      if previous_path = index[path.last]
        remove_by_path(previous_path)
      end
      new_charge = path.each.with_index(1).reduce(root) do |ch, (segment, idx)|
        if idx == path.size
          ch.charge(args.merge(guid: segment))
        else
          ch.find(segment) || ch.charge(guid: segment, name: segment)
        end
      end

      index[new_charge.guid] = path
      new_charge
    end

    def move(guid, new_parent_path)
      guid = guid.last if guid.is_a?(Array)
      previous_path = index[guid]
      return false unless previous_path

      ch = remove_by_path(previous_path)
      new_path = Array(new_parent_path) + [guid]
      add(new_path, ch.to_args)
    end

    def remove(guid)
      guid = guid.last if guid.is_a?(Array)
      path = index[guid]
      return nil unless path

      remove_by_path(path)
    end

    def amend(guid, args = {})
      guid = guid.last if guid.is_a?(Array)
      path = index[guid]
      return nil unless path

      ch = dig(*path)
      add(path, ch.to_args.merge(args))
    end

    def find(guid)
      path = index[guid]
      return nil unless path

      dig(*path)
    end

    def units
      root.charges.sum &:units
    end

    private

    attr_reader :root, :index

    def remove_by_path(path)
      path = Array(path).clone
      tguid = path.pop
      if child = dig(*path)
        index.delete(path.last)
        child.remove(tguid)
      end
    end
  end
end
