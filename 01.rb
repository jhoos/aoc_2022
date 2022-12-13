module Day01
  class << self
    def sum_cals(input)
      elf_calories = [0, 0]
      current_elf = 1
      input.each do |cals|
        if cals == ""
          current_elf += 1
          elf_calories[current_elf] = 0
        else
          elf_calories[current_elf] += cals.to_i
        end
      end
      elf_calories
    end

    def part_one(input)
      sum_cals(input).max
    end

    def part_two(input)
      cals = sum_cals(input).sort
      cals[-1] + cals[-2] + cals[-3]
    end
  end
end
