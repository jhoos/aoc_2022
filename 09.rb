require "set"

module Day09
  @snake_len = 2
  @snake_pos = []
  @places_tail_has_been = nil

  class << self
    def create_snake()
      @snake_pos = []
      @places_tail_has_been = Set.new()
      for x in 1..@snake_len
        @snake_pos += [[12, 15]]
      end
    end

    def sign(x)
      if x < 0
        -1
      elsif x > 0
        1
      else
        0
      end
    end

    def move(dx, dy)
      @snake_pos[0] = [@snake_pos[0][0] + dx, @snake_pos[0][1] + dy]

      for x in 1..@snake_len - 1
        if (@snake_pos[x - 1][0] - @snake_pos[x][0]).abs > 1
          @snake_pos[x][0] += sign(@snake_pos[x - 1][0] - @snake_pos[x][0])
          @snake_pos[x][1] += sign(@snake_pos[x - 1][1] - @snake_pos[x][1])
        elsif (@snake_pos[x - 1][1] - @snake_pos[x][1]).abs > 1
          @snake_pos[x][1] += sign(@snake_pos[x - 1][1] - @snake_pos[x][1])
          @snake_pos[x][0] += sign(@snake_pos[x - 1][0] - @snake_pos[x][0])
        end
      end
      @places_tail_has_been.add(
        [@snake_pos[@snake_len - 1][0], @snake_pos[@snake_len - 1][1]]
      )
    end

    def parse_move(dir, count)
      dx, dy =
        if dir == "L"
          [-1, 0]
        elsif dir == "R"
          [1, 0]
        elsif dir == "U"
          [0, -1]
        elsif dir == "D"
          [0, 1]
        end
      for x in 1..(count.to_i)
        move(dx, dy)
      end
      puts("#{@snake_pos}")
    end

    def part_one(input)
      create_snake
      input.join("\n").scan(/^(.) (\d+)$/) { parse_move(*_1) }
      @places_tail_has_been.length
    end

    def part_two(input)
      @snake_len = 10
      create_snake
      input.join("\n").scan(/^(.) (\d+)$/) { parse_move(*_1) }
      @places_tail_has_been.length
    end
  end
end
