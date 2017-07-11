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
        end
    )
end

def record_exec(name, *properties)
    instance_vars = properties.map { |prop| :"@#{prop}" }

    Object.const_set(
        name, Class.new
    ).class_exec(
        properties, instance_vars
    ) do |properties, instance_vars|
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

record_method_missing(:MethodMissing, *properties)
record_eval(:RecordEval, *properties)
record_exec(:RecordExec, *properties)


require 'benchmark'

c0 = MethodMissing.new(*1..26)
c1 = RecordEval.new(*1..26)
c2 = RecordExec.new(*1..26)

n = 100_000
Benchmark.bmbm do |bm|
    bm.report(:MethodMissing) { n.times { cc0 = MethodMissing.new(*1..26) } }
    bm.report(:RecordEval)    { n.times { cc1 = RecordEval.new(*1..26)    } }
    bm.report(:RecordExec)    { n.times { cc2 = RecordExec.new(*1..26)    } }
end

Benchmark.bmbm do |bm|
    bm.report(:MethodMissing) { n.times { c0.k } }
    bm.report(:RecordEval)    { n.times { c1.k } }
    bm.report(:RecordExec)    { n.times { c2.k } }
end
