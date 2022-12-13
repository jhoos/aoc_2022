module Day08
  class << self
    def parse_input(input)
      input.map { |r| r.chars.map { |c| c.to_i } }
    end

    def scan_visible(trees_visible, col, start_row, dir, height)
      range = (1..(height - 1)).to_a
      range.reverse! if dir == -1
      highest = trees_visible[col][start_row - dir][0]
      trees_visible[col][start_row - dir][1] = true
      for y in range
        trees_visible[col][y][1] = true if trees_visible[col][y][0] > highest
        highest = trees_visible[col][y][0] if trees_visible[col][y][0] > highest
      end
    end

    def part_one(input)
      trees = parse_input(input)
      width = trees[0].length - 1
      height = trees.length - 1
      trees_visible = trees.map { |r| r.map { |c| [c, false] } }

      for x in 1..(width - 1)
        scan_visible(trees_visible, x, 1, 1, height)
        scan_visible(trees_visible, x, height - 1, -1, height)
      end
      trees_visible = trees_visible.transpose
      for x in 1..(height - 1)
        scan_visible(trees_visible, x, 1, 1, width)
        scan_visible(trees_visible, x, width - 1, -1, width)
      end

      trees_visible.each do |r|
        puts r.map { |c| "#{c[0]}#{c[1] ? "V" : "."}" }.join("")
      end
      trees_visible.map { |r| r.map { |c| c[1] ? 1 : 0 }.sum }.sum + 4
    end

    def look(trees, x, y, width, height, dx, dy)
      # trees on the edges have at least one view length of 0, so just skip them because their overall score will be 0
      return 0 if x == 0 or y == 0 or x == width or y == height
      house_height = trees[x][y]
      visible_trees = 0
      x += dx
      y += dy
      while (0 <= x && x <= width) && (0 <= y && y <= height)
        if trees[x][y] < house_height
          visible_trees += 1
        else
          # we can see this tree but none past it
          visible_trees += 1
          # .. so stop here
          break
        end
        x += dx
        y += dy
      end
      visible_trees
    end

    def part_two(input)
      trees = parse_input(input)
      width = trees[0].length - 1
      height = trees.length - 1
      trees
        .map
        .with_index do |r, y|
          r
            .map
            .with_index do |c, x|
              look(trees, x, y, width, height, -1, 0) *
                look(trees, x, y, width, height, 1, 0) *
                look(trees, x, y, width, height, 0, -1) *
                look(trees, x, y, width, height, 0, 1)
            end
            .max
        end
        .max
    end
  end
end
