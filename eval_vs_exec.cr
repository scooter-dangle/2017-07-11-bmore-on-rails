macro my_record(name, ivar_type, *properties)
    class {{name}}
        def initialize(
            {% for prop in properties %}
                @{{prop}} : {{ivar_type}},
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

my_record C1, Int32, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z

c1 = C1.new(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26)

puts c1.k

start = Time.now
100_000.times { c1.k }
puts (Time.now - start)

start = Time.now
100_000.times do
    cc1 = C1.new(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26)
end
puts (Time.now - start)
