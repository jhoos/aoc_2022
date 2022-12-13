module Day13
  DEBUG = nil

  class << self
    def full_zip(l, r)
      l += [nil] * (r.length - l.length) if r.length > l.length
      l.zip(r)
    end

    def compare(left, right, level = 0)
      puts "  " * level + "- Compare #{left} vs #{right}" if DEBUG
      full_zip(left, right).each do |l, r|
        if l == nil
          puts "  " * level + "  - Left is empty" if DEBUG
          return -1
        end
        if r == nil
          puts "  " * level + "  - Right is empty" if DEBUG
          return 1
        end

        puts "  " * level + "  - Compare #{l} vs #{r}" if DEBUG
        result =
          if l.class == Integer && r.class == Integer
            l <=> r
          else
            l = [l] if l.class == Integer
            r = [r] if r.class == Integer
            compare(l, r, level + 2)
          end
        return result if result != 0
      end
      0
    end

    def part_one(input)
      input
        .join("\n")
        .split("\n\n")
        .map
        .with_index(1) do |i, idx|
          packets = i.split("\n")
          left = eval(packets[0])
          right = eval(packets[1])
          compare(left, right) == -1 ? idx : 0
        end
        .sum
    end

    def part_two(input)
      packets =
        (input + ["[[2]]", "[[6]]"])
          .select { |i| i != "" }
          .map { |s| eval(s) }
          .sort { |l, r| compare(l, r) }
      (packets.find_index([[2]]) + 1) * (packets.find_index([[6]]) + 1)
    end
  end
end
