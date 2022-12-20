require_relative "./aoclib"

module Day17
  class Sprite
    attr_reader :width, :height
    attr_accessor :position, :id

    def initialize(id, width, height, shape)
      @id = id
      @width = width
      @height = height
      @shape = shape
      @position = [0, 0]

      debug "Sprite ID #{@id}, width #{@width}, height #{@height}"
      debug "Sprite shape:"
      (0...@height).reverse_each do |y|
        debug "#{(0...@width).map { |x| at(x, y) ? "#" : "." }.join("")}"
      end
    end

    def at(x, y)
      @shape[(@height - 1 - y) * @height + x] != " "
    end
  end

  class Chasm < AocLibrary::Grid
    attr_reader :width

    def initialize(width)
      @height_offset = 0
      super(width, 50_0000, xlate: ->(x, y) { [x, y - @height_offset] })
      @heights = [0] * width
      @whoop = 0
    end

    def height_at(x)
      @heights[x] + @height_offset
    end

    def highest
      (0...@width).map { height_at(_1) }.max
    end

    def check_sprite_collision(sprite, new_pos)
      return true if @xlate.call(*new_pos)[1] < 0
      for x in 0...sprite.width
        for y in 0...sprite.height
          chasm_pos = AocLibrary::Grid.vec_add(x, y, *new_pos)
          if sprite.at(x, y) && get(*chasm_pos) == "#"
            debug "  Sprite [#{x}, #{y}] collided with chasm at chasm position #{chasm_pos}"
            return true
          end
        end
      end
      false
    end

    def update_heights_for_sprite(sprite)
      if sprite.id == 1 &&
           (0...7).detect { |x| get(x, sprite.position[1]) == "#" } == nil
        debug "## whoop there it is #{sprite.position} #{sprite.position[1] - @whoop}"
        @whoop = sprite.position[1]
      end
      for x in 0...sprite.width
        for y in 0...sprite.height
          chasm_pos = AocLibrary::Grid.vec_add(x, y, *sprite.position)
          if sprite.at(x, y)
            set(*chasm_pos, "#")
            @heights[chasm_pos[0]] = [
              @heights[chasm_pos[0]],
              chasm_pos[1] + 1
            ].max
          end
        end
      end
    end
  end

  class << self
    SPRITES = [
      Sprite.new(1, 4, 1, "####"),
      Sprite.new(2, 3, 3, " # ### # "),
      Sprite.new(3, 3, 3, "  #  ####"),
      Sprite.new(4, 1, 4, "####"),
      Sprite.new(5, 2, 2, "####")
    ]

    def push_sprite(chasm, sprite)
      dx = next_jet
      new_pos = AocLibrary::Grid.vec_add(*sprite.position, dx, 0)

      if new_pos[0] < 0 || new_pos[0] + sprite.width > chasm.width
        # move would be out of bounds, can't move it
        debug "  Sprite cannot move from #{sprite.position} to #{new_pos}, out of bounds"
        return
      end

      return if chasm.check_sprite_collision(sprite, new_pos)

      debug "  Sprite moved #{dx < 0 ? "left" : "right"} to #{new_pos}"
      sprite.position = new_pos
    end

    def fall_sprite(chasm, sprite)
      new_pos = AocLibrary::Grid.vec_add(*sprite.position, 0, -1)
      if new_pos[1] < 0 || chasm.check_sprite_collision(sprite, new_pos)
        chasm.update_heights_for_sprite(sprite)
        false
      else
        debug "  Sprite moved down to #{new_pos}"
        sprite.position = new_pos
        true
      end
    end

    def drop(chasm, sprite)
      sprite.position = [2, chasm.highest + 3]
      debug "Sprite #{sprite.id} starting at #{sprite.position}"
      begin
        push_sprite(chasm, sprite)
      end while fall_sprite(chasm, sprite)
    end

    def parse_input(nput)
      @jet = 0
      @jets = nput[0].chars.map { _1 == "<" ? -1 : 1 }
    end

    def next_jet
      @jet += 1
      @jets[(@jet - 1) % @jets.length]
    end

    def part_one(input)
      parse_input(input)
      chasm = Chasm.new(7)
      for x in 0...2022
        drop(chasm, SPRITES[x % SPRITES.length])
      end
      puts "#{@jet} #{@jet % @jets.length} #{@jets.length}"
      chasm.highest
    end

    def part_two(input)
      # return
      parse_input(input)
      chasm = Chasm.new(7)
      height_offset = 0
      patterns = {}
      x = 0
      while x < 1_000_000_000_000
        drop(chasm, SPRITES[x % SPRITES.length])
        remainder = @jet % @jets.length
        if remainder < 10
          patterns[remainder] ||= []
          patterns[remainder] += [[x, chasm.highest]]
          puts "#{remainder} #{patterns}"
          if patterns[remainder].length == 3
            p = patterns[remainder]
            if p[2][0] - p[1][0] == p[1][0] - p[0][0] &&
                 p[2][1] - p[1][1] == p[1][1] - p[0][1]
              drops_diff = p[2][0] - p[1][0]
              height_diff = p[2][1] - p[1][1]
              repeats = ((1_000_000_000_000 - x) / drops_diff)
              puts "detected repeat, will repeat #{repeats} times"
              x += repeats * drops_diff
              height_offset = repeats * height_diff
              puts "new x #{x}, height offset #{height_offset}"
            end
          end
        end
        x += 1
      end
      height_offset + chasm.highest
    end
  end
end
