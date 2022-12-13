module Day02
  class << self
    def score_it(input, my_plays)
      score = 0
      input.each do |strategy|
        you, me = strategy.split(" ")
        play = my_plays[me.to_sym]
        score += play[0] + play[1][you.to_sym]
      end
      score
    end

    def part_one(input)
      my_plays = {
        # first col is points for choice, second is points for outcome
        X: [1, { A: 3, B: 0, C: 6 }], # I chose rock
        Y: [2, { A: 6, B: 3, C: 0 }], # I chose paper
        Z: [3, { A: 0, B: 6, C: 3 }] # I chose scissor
      }
      score_it(input, my_plays)
    end

    def part_two(input)
      my_plays = {
        # first col is points for forced outcome, second is points for choice
        X: [0, { A: 3, B: 1, C: 2 }], # lose
        Y: [3, { A: 1, B: 2, C: 3 }], # draw
        Z: [6, { A: 2, B: 3, C: 1 }] # win
      }
      score_it(input, my_plays)
    end
  end
end
