# frozen_string_literal: true

# ===========================================
# Maze Shortest Path Finder
# Reads a maze and finds the shortest path from entry to exit
# ===========================================

# --------------------------
# Argument & File Handling
# --------------------------

def validate_arguments(arguments)
  return false unless arguments.length == 1
  file_path = arguments[0]
  return false unless File.exist?(file_path)
  return false unless File.readable?(file_path)
  return false if File.zero?(file_path)
  true
end

def read_file(path)
  lines = []
  File.open(path, 'r') do |file|
    while (line = file.gets)
      lines << line.chomp
    end
  end
  lines
end

# --------------------------
# Header Parsing
# --------------------------

def numeric?(char)
  char >= '0' && char <= '9'
end

def parse_header(header_line)
  height = ''
  width = ''
  chars = ''
  x_separator = false
  char_separator = false

  header_line.each_char do |char|
    if char == 'x'
      x_separator = true
      next
    end
    if numeric?(char) && !char_separator
      width += char if x_separator
      height += char unless x_separator
    end
    if x_separator && !numeric?(char)
      char_separator = true
    end
    chars += char if char_separator
  end

  wall = chars[0]
  free = chars[1]
  mark = chars[2]
  start = chars[3]
  goal = chars[4]

  [height.to_i, width.to_i, wall, free, mark, start, goal]
end

# --------------------------
# Maze Validation
# --------------------------

def valid_maze?(lines, height, width, allowed_chars, start, goal)
  return false if lines.length != height

  start_count = 0
  goal_count = 0

  lines.each do |line|
    return false if line.length != width
    line.each_char do |char|
      return false unless allowed_chars.include?(char)
      start_count += 1 if char == start
      goal_count += 1 if char == goal
    end
  end

  start_count == 1 && goal_count >= 1
end

# --------------------------
# Grid Conversion
# --------------------------

def to_grid(lines)
  lines.map(&:chars)
end

def find_entry(grid, start_char)
  grid.each_with_index do |row, r|
    row.each_with_index do |char, c|
      return [r, c] if char == start_char
    end
  end
  nil
end

# --------------------------
# Pathfinding - BFS
# --------------------------

def find_shortest_path(grid, start, goal, free, mark)
  queue = [start]
  visited = { start => true }
  parents = {}
  goal_pos = nil

  directions = {
    down: [1, 0],
    right: [0, 1],
    up: [-1, 0],
    left: [0, -1]
  }

  while !queue.empty?
    row, col = queue.shift

    directions.each do |_, (dy, dx)|
      new_row = row + dy
      new_col = col + dx

      next if new_row < 0 || new_row >= grid.length
      next if new_col < 0 || new_col >= grid[0].length

      cell = grid[new_row][new_col]
      next unless cell == free || cell == goal
      next if visited[[new_row, new_col]]

      visited[[new_row, new_col]] = true
      parents[[new_row, new_col]] = [row, col]
      queue << [new_row, new_col]

      if cell == goal
        goal_pos = [new_row, new_col]
        break
      end
    end

    break if goal_pos
  end

  if goal_pos
    current = goal_pos
    while current != start
      break if current.nil?
      row, col = current
      grid[row][col] = mark
      current = parents[current]
    end
  end
end

# --------------------------
# Grid Display
# --------------------------

def display_grid(grid)
  grid.each { |row| puts row.join }
end

# --------------------------
# Program Execution
# --------------------------

def main
  unless validate_arguments(ARGV)
    puts 'error: invalid arguments'
    return
  end

  content = read_file(ARGV[0])
  return puts 'error: invalid file content' if content.empty? || content.length < 2

  header_line = content[0]
  maze_lines = content[1..]

  height, width, wall, free, mark, start, goal = parse_header(header_line)
  allowed_chars = [wall, free, mark, start, goal]

  unless valid_maze?(maze_lines, height, width, allowed_chars, start, goal)
    puts 'error: invalid maze'
    return
  end

  grid = to_grid(maze_lines)
  entry_pos = find_entry(grid, start)

  if entry_pos.nil?
    puts 'error: no entry found'
    return
  end

  find_shortest_path(grid, entry_pos, goal, free, mark)
  display_grid(grid)
end

main if __FILE__ == $PROGRAM_NAME
