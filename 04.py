def parse_ranges(row):
  rng = lambda x: set(range(x[0], x[1] + 1))
  return [rng([int(a) for a in x.split("-")]) for x in row.strip().split(",")]

def parse_input(input):
  return [parse_ranges(r) for r in input]

def solve_1(input):
  return len([1 for x,y in parse_input(input) if max(len(x), len(y))==len(x.union(y))])

def solve_2(input):
  return len([1 for x,y in parse_input(input) if len(x.intersection(y)) > 0])

def solve_and_time(which, meth, input):
  from time import clock_gettime_ns, CLOCK_MONOTONIC
  start = clock_gettime_ns(CLOCK_MONOTONIC)
  print(f"Solution {which}: {meth(input)}")
  end = clock_gettime_ns(CLOCK_MONOTONIC)
  print(f"Took {(end - start)/1000000000} seconds to solve")
  print()

if __name__ == "__main__":
  import sys
  with open(sys.argv[1], "r") as f:
    input = f.readlines()
  #print("Solution 1:", solve_1(input))
  #print("Solution 2:", solve_2(input))
  solve_and_time(1, solve_1, input)
  solve_and_time(2, solve_2, input)
