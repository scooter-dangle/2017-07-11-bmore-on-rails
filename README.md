2017-07-11 talk to B'more on Rails
==================================
Loosely titled 'SYNTAX SUGAR IN THE RAW...Hype or Healthful?'
-------------------------------------------------------------

Concatenation of slides in `slides/`:


---

file: `slides/01.md`

---

## I are:
# Scott Steele

---

### I are at:
## Github: scooter-dangle

### I are paid via:
## Distil Networks in Arlington, VA

### I are slipping in a plug for:
## Rust DC meetup (so great!)

### Markdown are suitable for slides:
## Debatable

---

file: `slides/02.md`

---

### This slide intentionally left mediocre

---

file: `slides/03.md`

---

### As a Ruby n00b (aka, a r00b), magick was everything!
* `method_missing`
* `eval`
* Computers are wild and unpredictable, just like my code!

---

file: `slides/04.md`

---

### Goal
#### Create a class, but not the boring way:

```ruby
record_make :Coolness, :field1, :field2
```

should let me do

```ruby
so_cool = Coolness.new(880, 989)
so_cool.field1 #=> 880
so_cool.field2 #=> 989
```

So much less boring, right?!

_Note: Despite how simple this example is, I actually_ stole _it from someone else. Ary Borenszweig used it in a talk at Øredev 2016._

---

file: `slides/05.md`

---

### With `method_missing` & `eval`!

```ruby
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
```

```ruby
properties = [*:a..:z]
record_method_missing(:MethodMissing, *properties)
c0 = MethodMissing.new(*1..26)
c0.a #=> 1
```

Great!

---

---

---

---

_(Markdown lets you use horizontal lines to increase the vertical space. It's an advanced feature for power users though.)_

---

---

---

---

No! Not great!

In fact, just the worst!

---

file: `slides/06.md`

---

### With _just_ `eval`!

```ruby
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
```

```ruby
properties = [*:a..:z]
record_eval(:RecordEval, *properties)
c1 = RecordEval.new(*1..26)
c1.a #=> 1
```

Better! Ish!

---

file: `slides/07.md`

---

### With methods and functions!

```ruby
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
```

```ruby
properties = [*:a..:z]
record_exec(:RecordExec, *properties)
c2 = RecordExec.new(*1..26)
c2.a #=> 1
```

Comes from plants! Negligible tooth decay!

---

file: `slides/11.md`

---

### Computers are wild and crazy, but they know their own
* Haskell (lulz...i wish!)
* Elm (liddle bit)
* Crystal (from afar)
* Rust

### Whereas Ruby
>> Magick? Really?

> Yeah! I just need it for one sec!
> ---Ruby

Hey...what's the status on that magick? It's been like a bajillion milliseconds...

---

file: `slides/13.md`

---

### Crystal: Mebbeh muggle it with macros? Not magick?

```crystal
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
```

```crystal
my_record C1, Int32, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
c1 = C1.new(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26)
c1.a #=> 1
```

#### Syntax differences
* `def initialize(@k: SOME_TYPE); end` instead of `def initialize(k); @k = k; end`
* Types...wut?
* Some of the stickier sugar (e.g., `[*:a..:z]`) is unknown to this speaker

---

file: `slides/15.md`

---

### Yamool!

_Note: At this point, transitioned to talking about a recent work experience where I needed to make many queries against a decent-sized (but relatively simple) data structure. Started with giving a sample of what the data looked like._

```yaml
# data.yml
---
- :curl: curl --trace-ascii trace.tmp --silent --get --tlsv1.0   --user-agent 'Mozilla/5.0
    (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'  https://heartland-heartbleed-solutions.com
  :http_verb: get
  :tls: 1.0
  :cipher: 
  :is_secure: true
  :user_agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko)
    Chrome/41.0.2228.0 Safari/537.36
  :host: heartland-heartbleed-solutions.com
  :header_host: 
  :stdout: Quia omnis est odit repellat autem quibusdam. Qui eos optio est quis non.
    Quia natus ut in nisi. Dolor ut ut qui earum.
  :trace: Molestiae aut autem nobis quia sapiente id sed. Illo ipsam et temporibus
    quia. Rerum amet aut.
  :exitstatus: 0
  :time: '2017-06-17T09:35:03+00:00'

- :curl: curl --trace-ascii trace.tmp --silent --get --tlsv1.1   --user-agent 'Mozilla/5.0
    (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'  https://heartland-heartbleed-solutions.com
  :http_verb: get
  :tls: 1.1
  :cipher: 
  :is_secure: true
  :user_agent: Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko)
    Chrome/41.0.2228.0 Safari/537.36
  :host: heartland-heartbleed-solutions.com
  :header_host: 
  :stdout: Quasi illo nihil. Et enim aliquid ipsa in pariatur dolor vel. Eveniet et
    qui qui. A eos autem eaque nobis sequi earum numquam. Quia illum aspernatur.
  :trace: Voluptatem aut eum minus eos quae provident. Corrupti deserunt vel eaque
    provident dolores atque. Minus cupiditate vel et.
  :exitstatus: 0
  :time: '2017-06-17T09:35:04+00:00'

# ...
```

---

file: `slides/16.md`

---

### Find'em all

```ruby
data = YAML.load_file('data.yml')
```

```ruby
data.count { |element| element[:is_secure] && element[:host] =~ /\Awww/ }
```

---

file: `slides/17.md`

---

### Find'em all...prettily

```ruby
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
```

```ruby
data.count(&where(:is_secure, host: /\Awww/))
```

```ruby
data.count(&where(http_verb: 'get', host: /\Aheartland/, cipher: :nil?, tls: [:<, 1.2]))
```

---

file: `slides/18.md`

---

### Don't be so case-y

```ruby
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
```

About 2.5 times faster-ish

---

file: `slides/19.md`

---

### Awww...hmm...rly?

```ruby
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
```

```ruby
def where3(*requireds, **conds)
  eval(where3__string(*requireds, **conds))
end
```

Blerg. Mebbeh 2 to 3 times faster than previous.

---

file: `slides/20.md`

---

### Anything Ruby can do...

```crystal
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
```

---

file: `slides/21.md`

---

### Anything Ruby can do...

```crystal
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
```

---

file: `slides/22.md`

---

### Anything Ruby can do...

```crystal
def where2(requireds, conds)
  puts 'nope...no way :('
end
```

---

file: `slides/23.md`

---

# Eval!
## Iddy-o-matic!

* but be sooo careful with external data!
* for your first time out, maybe use `Object#inspect`

```ruby
# Often:
eval(some_obj.inspect) == some_obj
```

* still liable to get diabetus
