require_relative "./aoclib"

module Day14
  class << self
    SAND_START = [500, 0]

    def parse_input(nput, big_bottom = false)
      lines =
        nput
          .map { _1.scan(/(\d+),(\d+)/) }
          .map { _1.map { |x, y| [x.to_i, y.to_i] } }
      debug "#{lines}"

      min_x = lines.map { |l| l.map { |p| p[0] } }.flatten.min
      max_x =
        ([SAND_START[0]] + lines.map { |l| l.map { |p| p[0] } }).flatten.max
      max_y = lines.map { |l| l.map { |p| p[1] } }.flatten.max

      min_x, _, max_x, max_y =
        AocLibrary::Grid.bounding_box_for_points(
          [SAND_START] + lines.flatten.each_slice(2).to_a
        ).flatten

      if big_bottom
        max_y += 2
        max_x = 500 + max_y + 2
        min_x = [min_x, 500 - max_y - 2].min
      else
        # extend one column to the left so things can fall off
        min_x -= 1
      end
      debug "size max_y #{max_y} min_x #{min_x} max_x #{max_x}"

      xlate = ->(x, y) { [x - min_x, y] }

      @grid = AocLibrary::Grid.new(max_x, max_y, xlate: xlate)

      lines.each do
        _1.reduce do |a, b|
          debug "#{a} -> #{b}"
          @grid.draw(*a, *b, "#")
          b
        end
      end

      @grid.set(*SAND_START, "+")
      @grid.draw(min_x, max_y, max_x, max_y, "#") if big_bottom
    end

    def drop_sand
      cur_xy = SAND_START
      @grid.set(*cur_xy, "o") if ANIMATE
      dirs_to_try = [[0, 1], [-1, 1], [1, 1]]
      prev_xy = []
      while cur_xy[1] < @grid.height
        prev_xy = cur_xy
        cur_xy =
          dirs_to_try
            .map do
              next_xy = @grid.vec_add(*cur_xy, *_1)
              next_xy if %w[. +].include?(@grid.get(*next_xy))
            end
            .find(&:itself)
        debug "drop #{prev_xy} #{cur_xy}"
        unless cur_xy
          @grid.set(*prev_xy, "o")
          # tell outer loop to keep dropping unless we got clogged
          return prev_xy[1] != 0
        end

        # sleep 0.01
        @grid.set(*prev_xy, prev_xy == SAND_START ? "+" : ".") if ANIMATE
        @grid.set(*cur_xy, "o") if ANIMATE
      end
      # if we got here, we fell off the bottom
      false
    end

    def part_one(input)
      parse_input(input)
      dropped = 0
      dropped += 1 while drop_sand
      dropped
    end

    def part_two(input)
      parse_input(input, true)
      dropped = 1
      dropped += 1 while drop_sand
    end
  end
end
