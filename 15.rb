require_relative "./aoclib"

module Day15
  class << self
    def distance(a, b)
      (a[0] - b[0]).abs + (a[1] - b[1]).abs
    end

    def parse_input(nput)
      sensors =
        nput
          .scan_ints(
            /Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/
          )
          .map { |x| x.each_slice(2).to_a }
          .map { |sensor, beacon| [sensor, beacon, distance(sensor, beacon)] }
    end

    def row_coverage(sensors, key_row, count_beacons = false)
      sensors
        .map do |sensor, beacon, distance|
          distance_to_key_row = (sensor[1] - key_row).abs
          if distance_to_key_row <= distance
            width_left = distance - distance_to_key_row
            width_right = distance - distance_to_key_row
            if beacon[1] == key_row && !count_beacons
              width_left -= 1 if sensor[0] - width_left == beacon[0]
              width_right -= 1 if sensor[0] + width_right == beacon[0]
            end
            ((sensor[0] - width_left)..(sensor[0] + width_right))
          end
        end
        .select(&:itself)
        .sort do |r1, r2|
          r1.begin == r2.begin ? r1.end <=> r2.end : r1.begin <=> r2.begin
        end
        .reduce([]) do |memo, rng|
          if memo.last && memo.last.overlap?(rng)
            unless memo.last.cover?(rng)
              rng2 = memo.pop
              memo.push(rng2.begin..rng.end)
            end
          else
            memo.push(rng)
          end
          memo
        end
    end

    def covered_by_sensor(point, sensors)
      sensors.find do |sensor, _, distance_to_beacon|
        distance(sensor, point) <= distance_to_beacon
      end != nil
    end

    def part_one(input)
      sensors = parse_input(input)
      row_coverage(sensors, 2_000_000).map(&:size).sum
    end

    def part_two(input)
      sensors = parse_input(input)
      max_size = 4_000_000
      sensors
        .each
        .map do |sensor, _, distance_to_beacon|
          [
            sensor,
            distance_to_beacon,
            sensors.reject do |s, _, d|
              distance(sensor, s) > d + distance_to_beacon
            end
          ]
        end
        .map do |sensor, distance_to_beacon, nearby_sensors|
          out_of_range = distance_to_beacon + 1
          for z in 0..(distance_to_beacon)
            beacon =
              [
                [sensor[0] - out_of_range + z, sensor[1] + z],
                [sensor[0] + z, sensor[1] + out_of_range - z],
                [sensor[0] + out_of_range - z, sensor[1] - z],
                [sensor[0] - z, sensor[1] - out_of_range + z]
              ].reject do |p|
                p[0] < 0 || p[0] > max_size || p[1] < 0 || p[1] > max_size ||
                  covered_by_sensor(p, nearby_sensors)
              end
            return beacon[0][0] * max_size + beacon[0][1] if beacon.length == 1
          end
        end
    end

    def part_two_old(input)
      sensors = parse_input(input)
      max_size = 4_000_000
      beacon =
        for y in 0..max_size
          coverage =
            row_coverage(sensors, y, true).reject do |r|
              r.end < 0 || r.begin > 4_000_000
            end
          if coverage.length == 1
            break 0, y if coverage[0].begin == 1
            break max_size, y if coverage[0].end == max_size - 1
          end
          break coverage[0].end + 1, y if coverage.length == 2
        end
      beacon[0] * max_size + beacon[1]
    end
  end
end
