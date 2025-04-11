# frozen_string_literal: true

# ===========================================
# Sudoku Solver
# Solves and prints the solution of a Sudoku grid from a file
# Clean structure: argument validation, parsing, logic, display
# ===========================================

# --------------------------
# Input Validation
# --------------------------

def validate_arguments(arguments)
  return false unless arguments.length == 1
  file_path = arguments[0]
  return false unless File.exist?(file_path)
  return false unless File.readable?(file_path)
  return false if File.zero?(file_path)
  true
end

# --------------------------
# File & Grid Parsing
# --------------------------

def read_file(file_path)
  content = []
  File.open(file_path, 'r') do |file|
    while (line = file.gets)
      content << (line[-1] == "\n" ? line[0..-2] : line)
    end
  end
  content
end

def to_grid(lines)
  matrix = []
  i = 0
  while i < lines.length
    row = []
    j = 0
    while j < lines[i].length
      char = lines[i][j]
      row << (char == '.' ? nil : char.to_i)
      j += 1
    end
    matrix << row
    i += 1
  end
  matrix
end

# --------------------------
# Sudoku Logic
# --------------------------

def get_row(n, grid)
  grid[n]
end

def get_column(n, grid)
  result = []
  i = 0
  while i < 9
    result << grid[i][n]
    i += 1
  end
  result
end

def get_block(column, row, grid)
  result = []
  block_column_start = (column / 3) * 3
  block_row_start = (row / 3) * 3
  i = 0
  while i < 3
    j = 0
    while j < 3
      result << grid[block_row_start + i][block_column_start + j]
      j += 1
    end
    i += 1
  end
  result
end

def can_place?(row, col, n, grid)
  return false if get_row(row, grid).include?(n)
  return false if get_column(col, grid).include?(n)
  return false if get_block(col, row, grid).include?(n)
  true
end

def find_empty_cell(grid)
  row = 0
  while row < 9
    col = 0
    while col < 9
      return [row, col] if grid[row][col].nil?
      col += 1
    end
    row += 1
  end
  nil
end

def solve(grid)
  position = find_empty_cell(grid)
  return true if position.nil?

  row, col = position
  n = 1
  while n <= 9
    if can_place?(row, col, n, grid)
      grid[row][col] = n
      return true if solve(grid)
      grid[row][col] = nil
    end
    n += 1
  end
  false
end

# --------------------------
# Program Execution
# --------------------------

def main
  unless validate_arguments(ARGV)
    puts 'error'
    return
  end

  lines = read_file(ARGV[0])
  grid = to_grid(lines)

  if solve(grid)
    grid.each { |row| puts row.join }
  else
    puts 'error'
  end
end

main if __FILE__ == $PROGRAM_NAME
