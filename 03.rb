module Day03
  class << self
    def split_rucksack(rucksack)
      rucksack.chars.each_slice(rucksack.length / 2)
    end

    def priority(item)
      if item.ord >= "a".ord
        return item.ord - "a".ord + 1
      else
        return item.ord - "A".ord + 27
      end
    end

    def part_one(input)
      input.map { priority(split_rucksack(_1).reduce(&:&).first) }.sum
    end

    def part_two(input)
      input
        .each_slice(3)
        .map { priority(_1.map(&:chars).reduce(&:&).first) }
        .sum
    end
  end
end
