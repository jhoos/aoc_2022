require "yaml"

module Day07
  class << self
    def build_fs(input)
      cd_path = []
      fs = {}
      cd = fs
      input.each do
        if _1[0] == "$"
          if _1 == "$ cd /"
            cd_path = []
            cd = fs
          elsif _1 == "$ cd .."
            #puts "cd .. ! #{cd_path} #{fs}"
            cd_path.pop
            if cd_path.length == 0
              cd = fs
            else
              cd = fs.dig(*cd_path)
            end
            #puts "cd .. => #{cd_path} #{cd}"
          elsif _1[0..3] == "$ cd"
            dir = _1[5..]
            cd_path.push(dir)
            cd = cd[dir]
          end
        elsif _1[0..2] == "dir"
          dir = _1[4..]
          cd[dir] = {}
        else
          size, file = _1.split(" ")
          #puts "#{size} #{file}"
          cd[file] = size.to_i
        end
        #puts "#{_1} #{cd_path} #{cd}"
      end
      fs
    end

    def sum_fs(fs)
      sum = 0
      children = {}
      fs.each do |k, v|
        if v.class == Hash
          child_sum, child_children = sum_fs(v)
          sum += child_sum
          children[k] = [child_sum, child_children]
        else
          sum += v
        end
      end
      [sum, children]
    end

    def sum_under_100k(summed_fs)
      (summed_fs[0] <= 100_000 ? summed_fs[0] : 0) +
        summed_fs[1].map { sum_under_100k(_2) }.sum
    end

    def find_smallest_bigger_than(summed_fs, need)
      [summed_fs[0] >= need ? summed_fs[0] : 0] +
        summed_fs[1]
          .map { find_smallest_bigger_than(_2, need) }
          .flatten
          .select { _1 > 0 }
    end

    def part_one(input)
      sum_under_100k(sum_fs(build_fs(input)))
    end

    def part_two(input)
      sum = sum_fs(build_fs(input))
      free = 70_000_000 - sum[0]
      need = 30_000_000 - free
      find_smallest_bigger_than(sum_fs(build_fs(input)), need).sort[0]
    end
  end
end
