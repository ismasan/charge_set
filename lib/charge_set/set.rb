# frozen_string_literal: true

require 'forwardable'
require 'charge_set/charge'

module ChargeSet
  class Set
    extend Forwardable

    def_delegators :root, :guid, :name, :amount, :units, :charges, :total, :net_total, :dig, :find, :collect

    def initialize
      @root = Charge.new(
        guid: 'root',
        name: 'root'
      )
      @index = {}
    end

    def add(path, **args)
      path = Array(path)
      remove_by_path(index[path.last])
      add_by_path(path, args)
    end

    def upsert(path, **args)
      path = Array(path)
      if old_path = index[path.last]
        if old_path != path # we're also moving node
          move(path.last, path[0...-1])
        end
        amend(path.last, args)
      else
        add(path, **args)
      end
    end

    # add sub charge to an existing charge, by guid
    def add_to(parent_guid, child_path, **args)
      parent_path = index[parent_guid]
      return false unless parent_path

      add(parent_path + Array(child_path), **args)
    end

    def move(guid, new_parent_path)
      guid = guid.last if guid.is_a?(Array)
      previous_path = index[guid]
      return false unless previous_path

      ch = remove_by_path(previous_path)
      new_path = Array(new_parent_path) + [guid]
      add(new_path, **ch.to_args(true))
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
      add(path, **ch.to_args(true).merge(args))
    end

    def find(guid)
      path = index[guid]
      return nil unless path

      dig(*path)
    end

    def units
      root.charges.sum &:units
    end

    def to_ascii
      ascii(self)
    end

    private

    attr_reader :root, :index

    def ascii_lines(set)
      lines = [%([#{set.guid}] #{set.name} amount:#{set.amount} units:#{set.units} total:#{set.total})]
      set.charges.each_with_index do |child, index|
        child_lines = ascii_lines(child)
        if index < set.charges.size - 1
          child_lines.each_with_index do |line, idx|
            prefix = (idx == 0) ? "├── " : "│   "
            lines << "#{prefix}#{line}"
          end
        else
          child_lines.each_with_index do |line, idx|
            prefix = (idx == 0) ? "└── " : "    "
            lines << "#{prefix}#{line}"
          end
        end
      end
      lines
    end

    def ascii(set)
      ascii_lines(set).join("\n")
    end

    def add_by_path(path, args)
      path.each.with_index(1).reduce(root) do |ch, (segment, idx)|
        if idx == path.size
          ch = ch.charge(**args.merge(guid: segment))
          index[ch.guid] = path[0..idx]
          break ch
        end
        child = ch.find(segment)
        if !child
          child = ch.charge(guid: segment, name: segment)
          index[child.guid] = path[0...idx]
        end
        child
      end
    end

    def remove_by_path(path)
      return nil unless path

      path = Array(path).clone
      tguid = path.pop
      if child = dig(*path)
        child.remove(tguid)
      end
    end
  end
end
