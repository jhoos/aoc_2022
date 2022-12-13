module Day04
  class << self
    def parse_ranges(r)
      r.split(",").map { _1.split("-").map(&:to_i) }.map { Range.new(*_1) }
    end

    def part_one(input)
      input
        .map { parse_ranges(_1) }
        .select do |ranges|
          ranges[0].cover?(ranges[1]) || ranges[1].cover?(ranges[0])
        end
        .length
    end

    def part_two(input)
      input
        .map { parse_ranges(_1) }
        .select do |ranges|
          ranges[0].cover?(ranges[1].begin) ||
            ranges[0].cover?(ranges[1].end) ||
            ranges[1].cover?(ranges[0].begin) || ranges[1].cover?(ranges[0].end)
        end
        .length
    end
  end
end
