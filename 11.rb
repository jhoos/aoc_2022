module Day11
  class Monkey
    attr_reader :inspections, :items

    def initialize(
      items,
      operation,
      item_test,
      true_monkey,
      false_monkey,
      reduction
    )
      @items = items
      @operation = operation
      @item_test = item_test
      @true_monkey = true_monkey
      @false_monkey = false_monkey
      @reduction = reduction
      @inspections = 0
      puts "Made monkey #{self}"
    end

    def round!(monkeys)
      @items.map do |i|
        @inspections += 1
        puts "[TRACE]   Monkey inspects an item with a worry level of #{i}"
        w = @operation.call(i)
        puts "[TRACE]   Worry level becomes #{w}"
        w = @reduction.call(w)
        puts "[TRACE]   Monkey gets bored, worry is now #{w}"
        new_monkey = (@item_test.call(w) ? @true_monkey : @false_monkey)
        puts "[TRACE]   Item gets thrown to monkey #{new_monkey}"
        monkeys[new_monkey].give(w)
      end
      @items = []
    end

    def give(item)
      @items += [item]
    end

    def to_s
      "Items #{@items}, inspections #{@inspections}"
    end
  end

  class << self
    def make_monkeys(input, reduction)
      input
        .join("\n")
        .split("\n\n")
        .map do |txt|
          txt = txt.split("\n")
          items = txt[1].scan(/(\d+)/).map { |w| w[0].to_i }
          op, val = txt[2].scan(/old (.) (\d+|old)/)[0]
          op_lambda =
            if op == "*"
              if val == "old"
                ->(w) { w * w }
              else
                v = val.to_i
                ->(w) { w * v }
              end
            else
              if val == "old"
                ->(w) { w + w }
              else
                v = val.to_i
                ->(w) { w + v }
              end
            end
          test_val = txt[3].scan(/divisible by (\d+)/)[0][0].to_i
          test_monkeys =
            (txt[4] + txt[5]).scan(/monkey (\d+)/).flatten.map(&:to_i)
          test_lambda = ->(w) { w % test_val == 0 }
          Monkey.new(items, op_lambda, test_lambda, *test_monkeys, reduction)
        end
    end

    def round!(monkeys)
      monkeys.map.with_index do |m, i|
        puts("[TRACE] Monkey #{i}: #{m}")
        m.round!(monkeys)
      end
    end

    def part_one(input)
      monkeys = make_monkeys(input, ->(w) { (w / 3).to_i })
      for r in 1..20
        round!(monkeys)
      end
      monkeys.map { _1.inspections }.sort.reverse[0..1].reduce(&:*)
    end

    def part_two(input)
      common =
        input
          .join("\n")
          .scan(/divisible by (\d+)/)
          .map { _1[0].to_i }
          .reduce(&:*)
      puts "common #{common}"
      monkeys = make_monkeys(input, ->(w) { w % common })

      for r in 1..10_000
        puts "[DEBUG] *** Round #{r}"
        round!(monkeys)
        monkeys.each_with_index { |m, i| puts "[DEBUG] Monkey #{i}: #{m}" }
      end
      monkeys.map { _1.inspections }.sort.reverse[0..1].reduce(&:*)
    end
  end
end
