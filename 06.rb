module Day06
  class << self
    def detect(input, len)
      buffer = (" " * len).chars
      report = 0
      bad_wait = 0
      input[0]
        .chars
        .each
        .with_index(1) do
          report = _2
          buffer.unshift(_1).pop()
          if (q = buffer[1..].find_index(_1)) != nil
            bad_wait = [bad_wait, (len - 1) - q].max
          end
          #puts "#{_1} #{_2}, #{buffer.join("")}, #{buffer.include?(_1)}, #{bad_wait}"
          break if report > 3 && bad_wait <= 0
          bad_wait -= 1
        end
      report
    end

    def part_one(input)
      detect(input, 4)
    end

    def part_two(input)
      detect(input, 14)
    end
  end
end
