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

    def search_astar(valves, time_limit = 30)
      # First set up a Dijkstra graph that we can re-use
      dijkstra = DijkstraFast::Graph.new
      valves.each do |from_valve, egresses|
        egresses[1].each do |to_valve|
          dijkstra.add(from_valve, to_valve, distance: 1)
        end
      end

      pq = FastContainers::PriorityQueue.new(:max)
      result = [[], 0]

      # queue element is [loc, path, open, flow, total_pressure, minutes]
      pq.push(["AA", [], [], 0, 0, 0], 0)
      until pq.empty?
        loc, overall_path, open, total_flow, total_pressure, minutes = pq.next
        pq.pop
        remaining =
          valves
            .keys
            .reject do |to_valve|
              open.include?(to_valve) || to_valve == loc ||
                valves[to_valve][0] == 0
            end
            .map do |to_valve|
              distance, path = dijkstra.shortest_path(loc, to_valve)
              distance += 1
              flow = valves[to_valve][0]
              pressure = flow * (time_limit - minutes - distance)
              [to_valve, distance, path, flow, pressure]
            end
            .reject { |to_valve, dist, path, flow, pressure| pressure <= 0 }

        # short-circuit if there's no way the current path can beat the best
        next if total_pressure + remaining.sum { _1[4] } < result[1]

        debug " " * minutes +
                "Minute #{minutes}, at #{loc}, open valves #{open}, closed useful valves #{remaining.map(&:first)}, released #{total_pressure}"
        if remaining.length == 0 || minutes == time_limit
          if total_pressure > result[1]
            puts "Found better path, gets #{total_pressure} through #{open} in #{minutes} minutes"
            result = [overall_path, total_pressure]
          end
        else
          remaining.each do |to_valve, distance, path, flow, pressure|
            # value of turning on this valve is...
            if pressure > 0
              # debug " " * minutes +
              # "Queueing move to #{to_valve}, distance #{distance} path #{path} flow gain #{flow} overall pressure would be #{pressure}"
              path += ["open #{to_valve}"]
              pq.push(
                [
                  to_valve,
                  overall_path + path[1..],
                  open + [to_valve],
                  total_flow + flow,
                  total_pressure + pressure,
                  minutes + distance
                ],
                (time_limit - minutes - distance) * 100 + total_pressure +
                  pressure
              )
            end
          end
        end
      end
      result
    end

    def graph(valves, path = [])
      File.open("x.dot", "w") do |f|
        f.write("digraph {\n")
        valves.each do |v, egresses|
          f.write(
            "  #{v} [label=\"#{v}\\n#{egresses[0]}\",color=#{egresses[0] > 0 ? "red" : "black"}]\n"
          )
          egresses[1].each { |e| f.write("  #{v} -> #{e}\n") }
        end
        prev = "AA"
        path
          .each
          .with_index(1) do |v, m|
            if v.include? "open"
              v = v.split(" ")[1]
              f.write("  #{v} -> #{v} [label=#{m},color=blue]\n")
            else
              f.write("  #{prev} -> #{v} [label=#{m},color=blue]\n")
            end
            prev = v
          end
        f.write("}\n")
      end
      `circo x.dot -Tpng -o x.png ; open x.png`
    end

    def part_one(input)
      path, flow = search_astar(parse_input(input))
      # graph(parse_input(input), path)
      # path.each.with_index(1) { |p, m| puts "Minute #{m} #{p}\n" }
      flow
    end

    def part_two(input)
      1
    end
  end
end
