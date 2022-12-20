DEBUG = ENV.fetch("DEBUG", nil)
ANIMATE = ENV.fetch("ANIMATE", nil)
def debug(s)
  puts s if DEBUG
end

class String
  def scan_ints(expr)
    self.scan(expr).map { |m| m.map(&:to_i) }
  end
end

class Array
  def scan(expr)
    self.map { _1.scan(expr) }.map(&:first)
  end

  def scan_ints(expr)
    self.map { _1.scan_ints(expr) }.map(&:first)
  end
end

class Range
  def overlap?(other)
    self.cover?(other.begin) || self.cover?(other.end)
  end
end

module AocLibrary
  module ColorOutput
    extend self

    colors = %w[red green yellow blue magenta cyan gray]

    colors
      .each
      .with_index(1) do |color_name, idx|
        define_method(color_name) { |text| color(text, idx) }
        define_method("bold_#{color_name}") do |text|
          color(text, idx, bold: true)
        end
      end

    def color(text, color, bold: false)
      bold_code = bold ? "1;" : ""
      "\e[#{bold_code}3#{color}m#{text}\e[0m"
    end
  end

  class Grid
    attr_reader :width, :height

    class << self
      def bounding_box_for_points(points)
        top_left = points.first
        bot_right = points.first
        points.each do |p|
          top_left = [[top_left[0], p[0]].min, [top_left[1], p[1]].min]
          bot_right = [[bot_right[0], p[0]].max, [bot_right[1], p[1]].max]
        end

        [top_left, bot_right]
      end

      def expand_box(tl, br, delta)
        [[tl[0] - delta, tl[1] - delta], [br[0] + delta, br[1] + delta]]
      end

      def vec_add(x, y, dx, dy)
        [x + dx, y + dy]
      end
    end

    def initialize(width, height, initial: ".", xlate: ->(x, y) { [x, y] })
      @grid = []
      @width = width
      @height = height
      @xlate = xlate
      xwidth, xheight = @xlate.call(width, height)
      @xwidth = xwidth
      @xheight = xheight
      debug "grid size after translation: #{xwidth}, #{xheight}"
      for y in 0..xheight
        @grid[y] = [initial] * xwidth
      end

      print "\033[2J\033[H" if ANIMATE
      print "\n" * (@xheight + 2) if ANIMATE
      render
    end

    def get(x, y)
      x2, y2 = @xlate.call(x, y)
      @grid[y2][x2]
    end

    def set(x, y, char)
      x2, y2 = @xlate.call(x, y)
      @grid[y2][x2] = char
      print "\0337\033[#{y2 + 1};#{x2 + 1}H#{char}\0338" if ANIMATE
    end

    def draw(x1, y1, x2, y2, char)
      # TODO this might run away with weird slopes, TBD
      dx = x2 - x1 * 1.0
      dy = y2 - y1 * 1.0
      factor = [dx.abs, dy.abs].max
      dx /= factor if dx != 0
      dy /= factor if dy != 0
      cur_x, cur_y = x1, y1
      until cur_x.to_int == x2 and cur_y.to_int == y2
        set(cur_x.to_int, cur_y.to_int, char)
        cur_x += dx
        cur_y += dy
      end
      set(cur_x.to_int, cur_y.to_int, char)
    end

    def render
      print "\0337\033[H" if ANIMATE
      @grid.each { print "#{_1.join("")}\033[0K\n" } if ANIMATE
      print "\033[0K\0338" if ANIMATE
    end
  end
end
