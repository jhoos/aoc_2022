require_relative "./aoclib"
require "fc"
require "dijkstra_fast"

module Day16
  class << self
    def parse_input(nput)
      nput
        .scan(
          /Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? (.*)/
        )
        .map do |row|
          [row[0], [row[1].to_i, row[2].scan(/([A-Z]{2})/).flatten]]
        end
        .to_h
    end

    def search_astar(valves, time_limit = 30, workers = 1)
      # First set up a Dijkstra graph that we can re-use
      dijkstra = DijkstraFast::Graph.new
      valves.each do |from_valve, egresses|
        egresses[1].each do |to_valve|
          dijkstra.add(from_valve, to_valve, distance: 1)
        end
      end

      useful_valves = valves.keys.reject { |v| valves[v][0] == 0 }

      pq = FastContainers::PriorityQueue.new(:max)
      result = [[], 0]

      # queue element is [[workers(loc, path, minutes)], open, total_pressure]
      pq.push([(1..workers).map { ["AA", [], 0] }, [], 0], 0)
      until pq.empty?
        workers, open, total_pressure = pq.next
        pq.pop

        remaining =
          workers
            .map
            .with_index do |data, worker_idx|
              loc, path, minutes = data
              useful_valves
                .reject do |to_valve|
                  open.include?(to_valve) || to_valve == loc
                end
                .map do |to_valve|
                  distance, path = dijkstra.shortest_path(loc, to_valve)
                  pressure =
                    valves[to_valve][0] * (time_limit - minutes - distance - 1)
                  [to_valve, distance + 1, path, pressure, worker_idx]
                end
                .reject do |to_valve, distance, path, pressure, worker_idx|
                  pressure <= 0
                end
            end
            .reduce(&:+)

        # short-circuit if there's no way the current paths can beat the best
        next if total_pressure + remaining.sum { _1[3] } < result[1]

        if remaining.sum { _1.length } == 0
          if total_pressure > result[1]
            puts "Found better path, gets #{total_pressure} opening #{open} minutes #{workers.map(&:last)}"
            result = [workers.map { _1[1] }, total_pressure]
          end
        else
          remaining.each do |to_valve, distance, path, pressure, worker_idx|
            loc, path, minutes = workers[worker_idx]
            debug " " * minutes +
                    "Queueing worker #{worker_idx} move to #{to_valve}, distance #{distance} path #{path} overall pressure would be #{pressure}"
            path += ["open #{to_valve}"]

            # [workers(loc, path, minutes)], open, total_pressure
            pq.push(
              [
                workers.map.with_index do |w, i|
                  worker_idx == i ? [to_valve, path, minutes + distance] : w
                end,
                open + [to_valve],
                total_pressure + pressure
              ],
              (time_limit - minutes - distance) * 100 + total_pressure +
                pressure
            )
          end
        end
      end
      result
    end

    def part_one(input)
      search_astar(parse_input(input))[1]
    end

    def part_two(input)
      search_astar(parse_input(input), 26, 2)[1]
    end
  end
end
