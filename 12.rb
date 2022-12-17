require "fc"

module Day12
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

  class Terrain
    @is_start = false
    @is_end = false
    @walk_dir = nil
    attr_reader :height, :score, :from, :x, :y
    attr_writer :score

    def initialize(terrain, x = -1, y = -1)
      @x = x
      @y = y
      if terrain == "S"
        @is_start = true
        terrain = "a"
      elsif terrain == "E"
        @is_end = true
        terrain = "z"
      end
      @height = terrain.ord
      @walk_dir = nil
      @score = 1e+38
    end

    def to_s
      if walked?
        ColorOutput.yellow("*")
      elsif @is_start
        ColorOutput.green("S")
      elsif @is_end
        ColorOutput.red("E")
      else
        @height.chr
      end
    end

    def walk(from, score)
      if score < @score
        @score = score
        @from = from
      end
    end

    def walked?
      @score < 1e+37
    end
  end

  class << self
    @terrain = nil
    @start = nil
    @end = nil
    @best_core = 1e+38

    def parse_input(nput)
      puts "\033[2J"
      puts "\033[H"
      width = nput[0].length + 2
      barrier = Terrain.new("~")
      @terrain = [[barrier] * width]
      nput
        .each
        .with_index(1) do |r, y|
          @terrain[y] = []
          @terrain[y][0] = barrier
          r
            .chars
            .each
            .with_index(1) do |t, x|
              @terrain[y][x] = Terrain.new(t, x, y)
              @start = [x, y] if t == "S"
              @end = [x, y] if t == "E"
            end
          @terrain[y][width - 1] = barrier
        end
      @terrain += [[barrier] * width]
      @directions = [[-1, 0], [0, 1], [1, 0], [0, -1]]
    end

    def render_terrain
      puts "\033[H"
      @terrain.each { |r| puts r.map(&:to_s).join("") }
    end

    def render_terrain_with_path
      @terrain.each do |r|
        puts r
               .map { |t|
                 if @path.include?([t.x, t.y])
                   ColorOutput.blue(t.height.chr)
                 else
                   t.height.chr
                 end
               }
               .join("")
      end
      1
    end

    def distance(x, y, cur_height, goal)
      (goal[0] - x)**2 + (goal[1] - y)**2 +
        (terrain_at(x, y).height - terrain_at(*goal).height)**2 +
        (cur_height - terrain_at(x, y).height) * 100
    end

    def terrain_at(x, y)
      @terrain[y][x]
    end

    @directions = nil

    def can_walk(cur_xy, dxy)
      terrain_at(*vec_add(cur_xy, dxy)).height - terrain_at(*cur_xy).height <= 1
    end

    def vec_add(a, b)
      [a[0] + b[0], a[1] + b[1]]
    end

    def walk(start, goal)
      q = FastContainers::PriorityQueue.new(:min)
      q.push([start, 0], 0)

      until q.empty?
        cur_xy, score = q.next
        q.pop
        render_terrain
        puts "consider #{cur_xy} #{score}"
        @directions
          .select do |d|
            terrain = terrain_at(*vec_add(cur_xy, d))
            can_walk(cur_xy, d) && terrain.score > score && !terrain.walked?
          end
          .map do |d|
            [d, distance(*vec_add(cur_xy, d), terrain_at(*cur_xy).height, goal)]
          end
          .sort_by { |dd| dd[1] }
          .each do |dd|
            new_xy = vec_add(cur_xy, dd[0])
            terrain_at(*new_xy).walk(cur_xy, score + 1)
            return score + 1 if new_xy == goal
            puts " -> #{new_xy} #{score**2 + dd[1]} #{score + 1}"
            # I ended up having to weight the "distance to here" score rediculously to force the algorithm to go
            # around a hill the right way, which sadly devolves this into a BFS. Probably this means the "distance to
            # goal" score is entirely too naive.
            q.push([new_xy, score + 1], (score**2).abs + dd[1])
          end
      end
    end

    def part_one(nput)
      parse_input(nput)
      render_terrain
      score = walk(@end, @start)
      @path = [@end]
      @path += [terrain_at(*@path[-1]).from] while @path[-1] != @end
      render_terrain_with_path
      puts "\n" * 6
      score
    end

    def part_two(nput)
      for x in (0..@path.length - 1)
        @directions.each do |d|
          new_xy = vec_add(@path[x], d)
          old_t = terrain_at(*@path[x])
          new_t = terrain_at(*new_xy)
          if new_t.height == "a".ord && old_t.height == "b".ord
            @path = @path[0..x]
            render_terrain_with_path
            return x
          end
        end
      end
    end
  end
end
