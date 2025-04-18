# frozen_string_literal: true

# ===========================================
# Largest Square Finder
# Reads a file describing a grid and finds the largest square
# of empty cells to fill with a full character
# ===========================================

# --------------------------
# Argument & File Handling
# --------------------------

def validate_arguments(args)
  return false unless args.length == 1
  file_path = args[0]
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
  line_count = ''
  empty = ''
  obstacle = ''
  full = ''

  header_line.each_char do |char|
    if numeric?(char)
      line_count += char
      next
    end
  
    if empty == ''
      empty = char
      next
    end
  
    if obstacle == ''
      obstacle = char
      next
    end
  
    if full == ''
      full = char
    end
  end

  [line_count.to_i, empty, obstacle, full]
end

# --------------------------
# Map Validation
# --------------------------

def valid_char?(char, empty, obstacle, full)
  char == empty || char == obstacle || char == full
end

def validate_map(lines, expected_rows, empty, obstacle, full)
  return false if lines.length != expected_rows

  expected_cols = lines[0].length
  lines.each do |line|
    return false if line.length != expected_cols
    line.each_char do |char|
      return false unless valid_char?(char, empty, obstacle, full)
    end
  end

  true
end

# --------------------------
# Grid Conversion
# --------------------------

def to_grid(lines)
  grid = []
  lines.each do |line|
    grid << line.chars
  end
  grid
end

def to_int_map(grid, empty, obstacle)
  int_map = []

  grid.each do |row|
    int_row = []
    row.each do |char|
      int_row << (char == empty ? 0 : 1)
    end
    int_map << int_row
  end

  int_map
end

# --------------------------
# Square Detection
# --------------------------

def square_possible?(map, row, col, size)
  return false if row + size > map.length
  return false if col + size > map[0].length

  (row...(row + size)).each do |r|
    (col...(col + size)).each do |c|
      return false if map[r][c] != 0
    end
  end

  true
end

def find_largest_square(map)
  best_row = 0
  best_col = 0
  max_size = 0

  (0...map.length).each do |row|
    (0...map[0].length).each do |col|
      next unless map[row][col] == 0
  
      size = 1
      while square_possible?(map, row, col, size)
        if size > max_size
          max_size = size
          best_row = row
          best_col = col
        end
        size += 1
      end
    end
  end

  [best_row, best_col, max_size]
end

# --------------------------
# Grid Update & Display
# --------------------------

def fill_square(grid, row, col, size, full)
  (row...(row + size)).each do |r|
    (col...(col + size)).each do |c|
      grid[r][c] = full
    end
  end
end

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
  if content.empty? || content[0].nil?
    puts 'error: invalid file content'
    return
  end

  if content.length < 2
    puts 'error: invalid file content'
    return
  end

  header_line = content[0]
  map_lines = content[1..]

  row_count, empty, obstacle, full = parse_header(header_line)

  unless validate_map(map_lines, row_count, empty, obstacle, full)
    puts 'error: invalid map'
    return
  end

  grid = to_grid(map_lines)
  int_map = to_int_map(grid, empty, obstacle)
  row, col, size = find_largest_square(int_map)
  fill_square(grid, row, col, size, full)
  display_grid(grid)
end

main if __FILE__ == $PROGRAM_NAME
