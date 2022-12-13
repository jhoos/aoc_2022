module Day05
  class << self
    def parse_input(input)
      stacks = []
      input
        .select { _1.include? "[" }
        .each do
          _1
            .chars
            .each_slice(4)
            .with_index(1) do |crate, idx|
              stacks[idx] ||= []
              stacks[idx].unshift(crate[1]) if crate[1] != " "
            end
        end

      commands =
        input
          .select { _1.include? "move" }
          .map do
            _1.match(/move (\d+) from (\d+) to (\d+)/).captures.map(&:to_i)
          end

      [stacks, commands]
    end

    def part_one(input)
      stacks, commands = parse_input(input)
      commands.each do
        count, from, to = _1
        for i in 1..count
          stacks[to].push(stacks[from].pop)
        end
      end

      stacks.select { _1 }.map { _1[-1] }.join("")
    end

    def part_two(input)
      stacks, commands = parse_input(input)
      commands.each do
        count, from, to = _1
        temp = []
        for i in 1..count
          temp.push(stacks[from].pop)
        end
        for i in 1..count
          stacks[to].push(temp.pop)
        end
      end

      stacks.select { _1 }.map { _1[-1] }.join("")
    end
  end
end
