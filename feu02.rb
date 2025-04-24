# frozen_string_literal: true

# ===========================================
# Shape Finder
# Finds the top-left position of a shape inside a board
# Supports minimal file parsing, shape matching, and structured output
# ===========================================

# --------------------------
# Argument & File Handling
# --------------------------

def validate_arguments(arguments)
  return false unless arguments.length == 2
  arguments.each do |file_path|
    return false unless File.exist?(file_path)
    return false unless File.readable?(file_path)
    return false if File.zero?(file_path)
  end
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
    grid << line.chars
  end
  grid
end

# --------------------------
# Shape Matching Logic
# --------------------------

def shape_fits?(board, shape, row, col)
  return false if row + shape.length > board.length
  return false if col + shape[0].length > board[0].length
  true
end

def shape_matches_at?(board, shape, row, col)
  shape.each_with_index do |shape_row, i|
    shape_row.each_with_index do |char, j|
      next if char == ' '
      return false if board[row + i][col + j] != char
    end
  end
  true
end

def find_shape(board, shape)
  (0...board.length).each do |row|
    (0...board[0].length).each do |col|
      if shape_fits?(board, shape, row, col) && shape_matches_at?(board, shape, row, col)
        puts "Found !"
        puts "Coordinates : #{col},#{row}"
        display_shape(shape, col, row, board[0].length)
        return
      end
    end
  end
  puts "Not found"
end

# --------------------------
# Grid Display
# --------------------------

def display_shape(shape, offset_x, offset_y, board_width)
  offset_y.times { puts '-' * board_width }

  shape.each do |row|
    line = ''
    (0...board_width).each do |col|
      if col < offset_x
        line << '-'
      elsif (col - offset_x) < row.length
        char = row[col - offset_x]
        line << (char == ' ' ? '-' : char)
      else
        line << '-'
      end
    end
    puts line
  end
end

# --------------------------
# Program Execution
# --------------------------

def main
  unless validate_arguments(ARGV)
    puts 'error: invalid arguments'
    return
  end

  board_lines = read_file(ARGV[0])
  shape_lines = read_file(ARGV[1])

  board = to_grid(board_lines)
  shape = to_grid(shape_lines)

  find_shape(board, shape)
end

main if __FILE__ == $PROGRAM_NAME
