# frozen_string_literal: true

# ===========================================
# Sudoku Solver
# Solves and prints the solution of a Sudoku grid from a file
# Structured: argument validation, parsing, solving, display
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
# Grid Conversion
# --------------------------

def to_grid(lines)
  grid = []
  lines.each do |line|
    row = line.chars.map { |c| c == '.' ? nil : c.to_i }
    grid << row
  end
  grid
end

# --------------------------
# Sudoku Solving Logic
# --------------------------

def get_row(row_index, grid)
  grid[row_index]
end

def get_column(col_index, grid)
  grid.map { |row| row[col_index] }
end

def get_block(col, row, grid)
  block = []
  start_row = (row / 3) * 3
  start_col = (col / 3) * 3

  (0...3).each do |i|
    (0...3).each do |j|
      block << grid[start_row + i][start_col + j]
    end
  end

  block
end

def can_place?(row, col, num, grid)
  !get_row(row, grid).include?(num) &&
    !get_column(col, grid).include?(num) &&
    !get_block(col, row, grid).include?(num)
end

def find_empty_cell(grid)
  (0...9).each do |row|
    (0...9).each do |col|
      return [row, col] if grid[row][col].nil?
    end
  end
  nil
end

def solve(grid)
  cell = find_empty_cell(grid)
  return true if cell.nil?

  row, col = cell
  (1..9).each do |n|
    if can_place?(row, col, n, grid)
      grid[row][col] = n
      return true if solve(grid)
      grid[row][col] = nil
    end
  end

  false
end

# --------------------------
# Program Execution
# --------------------------

def main
  unless validate_arguments(ARGV)
    puts 'error: invalid arguments'
    return
  end

  lines = read_file(ARGV[0])
  grid = to_grid(lines)

  if solve(grid)
    grid.each { |row| puts row.join }
  else
    puts 'error: no solution'
  end
end

main if __FILE__ == $PROGRAM_NAME
