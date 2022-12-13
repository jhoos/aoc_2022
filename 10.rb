module Day10
  class << self
    def reset
      @x = 1
      @cycles = 0
      @crt = []
      for y in 0..5
        @crt[y] = []
        for x in 0..39
          @crt[y] += ["."]
        end
      end
    end

    def render_crt
      @crt.each { |r| puts "#{r.join("")}" if r }
    end

    def do_instr(instr, val)
      if instr == "addx"
        [@x + val.to_i, 2]
      elsif instr == "noop"
        [@x, 1]
      end
    end

    def sprite
      out = "." * 40
      for x in (@x - 1)..(@x + 1)
        out[x] = "#" if x >= 0
      end
      out
    end

    def part_one(input)
      reset
      cycles_of_concern = [20, 60, 100, 140, 180, 220]
      input
        .map do |line|
          instr, val = line.split(" ")
          new_x, cycles = do_instr(instr, val)
          @cycles += cycles
          signal = 0
          if @cycles % 20 == 0 || (@cycles % 20 == 1 && cycles == 2)
            cycle = (@cycles - @cycles % 20)
            signal = cycle * @x if cycles_of_concern.include? cycle
          end
          @x = new_x
          signal
        end
        .sum
    end

    def part_two(input)
      reset
      input.each do |line|
        instr, val = line.split(" ")
        new_x, cycles = do_instr(instr, val)
        cur_sprite = sprite
        for p in @cycles..(@cycles + cycles - 1)
          y = p / 40
          x = p % 40
          @crt[y][x] = cur_sprite[x]
        end
        @cycles += cycles
        @x = new_x
      end
      render_crt
    end
  end
end
