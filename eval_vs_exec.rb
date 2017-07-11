def record_method_missing(name, *properties)
    eval %(
class #{name}
    def initialize(#{properties.join(", ")})
        #{properties.map { |prop| "@#{prop} = #{prop}" }.join(?\n)}
    end

    def method_missing(meth)
        eval "@\#{meth}"
    end
end
    )
end

def record_eval(name, *properties)
    eval %(
class #{name}
    def initialize(#{properties.join(", ")})
        #{properties.map { |prop| "@#{prop} = #{prop}" }.join(?\n)}
    end
    #{properties.map { |prop| "def #{prop}; @#{prop}; end" }.join(?\n)}
end)
end

def record_exec(name, *properties)
    instance_vars = properties.map { |prop| :"@#{prop}" }

    Object.const_set(name, Class.new).class_exec(properties, instance_vars) do |properties, instance_vars|
        define_method(:initialize) do |*props|
            instance_vars.zip(props) do |ivar, prop|
                self.instance_variable_set(ivar, prop)
            end
        end

        properties.zip(instance_vars).each do |prop, ivar|
            define_method(prop) do
                self.instance_variable_get(ivar)
            end
        end
    end
end

properties = [*:a..:z]

record_method_missing(:C0, *properties)
record_eval(:C1, *properties)
record_exec(:C2, *properties)


#<<HERE
require 'benchmark'

c0 = C0.new(*1..26)
c1 = C1.new(*1..26)
c2 = C2.new(*1..26)

n = 100_000
Benchmark.bmbm do |bm|
    bm.report(:C0) { n.times { c0.k } }
    bm.report(:C1) { n.times { c1.k } }
    bm.report(:C2) { n.times { c2.k } }
end

Benchmark.bmbm do |bm|
    bm.report(:C0) { n.times { cc0 = C0.new(*1..26) } }
    bm.report(:C1) { n.times { cc1 = C1.new(*1..26) } }
    bm.report(:C2) { n.times { cc2 = C2.new(*1..26) } }
end
#HERE



<<CRYSTAL
macro record(name, *properties)
    class {{name}}
        def initialize(
            {% for prop in properties %}
                @{{prop}},
            {% end %}
        )
        end

        {% for prop in properties %}
            def {{prop}}
                @{{prop}}
            end
        {% end %}
    end
end
CRYSTAL
