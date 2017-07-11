def where(*requireds, **conds)
  ->(record) do
    record.values_at(*requireds).all? && conds.all? do |k, val|
      case [val.class]
      when [Regexp]
        record[k] && record[k] =~ val
      when [Symbol]
        record[k].send(val)
      when [Array]
        record[k].send(*val)
      else
        record[k] == val
      end
    end
  end
end

def where2(*requireds, **conds)
  conditions = conds.map do |key, val|
    case [val.class]
    when [Regexp]
      ->(record) { record[key] && record[key] =~ val }
    when [Symbol]
      ->(record) { record[key].send(val) }
    when [Array]
      ->(record) { record[key].send(*val) }
    else
      ->(record) { record[key] == val }
    end
  end

  ->(record) { record.values_at(*requireds).all? && conditions.all? { |cond| cond[record] } }
end

def where3__string(*requireds, **conds)
  requireds_strings = requireds.map do |key|
    "record[#{key.inspect}]"
  end

  conditions_strings = conds.map do |key, val|
    case [val.class]
    when [Regexp]
      "record[#{key.inspect}] && record[#{key.inspect}] =~ #{val.inspect}"
    when [Symbol]
      "record[#{key.inspect}].send(#{val.inspect})"
    when [Array]
      "record[#{key.inspect}].send(#{val.map(&:inspect).join(', ')})"
    else
      "record[#{key.inspect}] == #{val.inspect}"
    end
  end

  "->(record) { #{[*requireds_strings, *conditions_strings, 'true'].join(' && ')} }"
end

def where3(*requireds, **conds)
  eval(where3__string(*requireds, **conds))
end
