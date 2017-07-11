def where(requireds, conds)
  ->(record) do
    record.values_at(*requireds).all? && conds.all? do |k, val|
      case [val.class]
      when [Regex]
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

def where2(requireds, conds)
  conditions = conds.map do |key, val|
    case [val.class]
    when [Regex]
      ->(record : Hash(Symbol, String | Bool | Float32 | Float64 | Nil | Int32 | Int64)) { record[key] && record[key] =~ val && true }
    when [Symbol]
      ->(record : Hash(Symbol, String | Bool | Float32 | Float64 | Nil | Int32 | Int64)) { record[key].send(val) && true }
    when [Array]
      ->(record : Hash(Symbol, String | Bool | Float32 | Float64 | Nil | Int32 | Int64)) { record[key].send(*val) && true }
    else
      ->(record : Hash(Symbol, String | Bool | Float32 | Float64 | Nil | Int32 | Int64)) { record[key] == val && true }
    end
  end

  ->(record : Hash(Symbol, String | Bool | Float32 | Float64 | Nil | Int32 | Int64)) { record.values_at(*requireds).all? && conditions.all? { |cond| cond[record] } }
end

# def where3__string(requireds, conds)
#   requireds_strings = [] of String

#   requireds.each do |key|
#     requireds_strings.push("record[#{key.inspect}]")
#   end

#   conditions_strings = [] of String
#   conds.each do |key, val|
#     conditions_strings.push(
#       if val.is_a?(Regex)
#         "record[#{key.inspect}] && record[#{key.inspect}] =~ #{val.inspect}"
#       elsif val.is_a?(Symbol)
#         "record[#{key.inspect}].send(#{val.inspect})"
#       elsif val.is_a?(Array)
#         "record[#{key.inspect}].send(#{val.map(&.inspect).join(", ")})"
#       else
#         "record[#{key.inspect}] == #{val.inspect}"
#       end
#     )
#   end

#   "->(record) { #{(requireds_strings + conditions_strings + ["true"]).join(" && ")} }"
# end

# def where3(requireds, conds)
#   eval(where3__string(requireds, conds))
# end

puts({ verb: /head/ }.class)
{ verb: ["head"] }.each { |key, val| puts([key.class, val.class]) }
# hash = { :http_verb => /head/ } of Symbol => (Regex | Array(Symbol | String))
# puts(where3__string([ :is_secure ], hash))
# puts(where3([ :is_secure ], { :http_verb => /head/, :tls_version => [:>, 1.0] }).call({:tls_version => 1.2}))
puts(where2([ :is_secure ], { :http_verb => /head/, :tls_version => [:>, 1.0] }).call({:tls_version => 1.2}))
