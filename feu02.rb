# frozen_string_literal: true

# ===========================================
# Find a shape
# Displays the top-left position of a shape inside a board, if found
# Supports minimal file parsing, shape matching, and structured output
# ===========================================

# --------------------------
# Input Validation
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

# --------------------------
# File & Matrix Parsers
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

def to_char_matrix(lines)
  matrix = []
  i = 0
  while i < lines.length
    row = []
    j = 0
    while j < lines[i].length
      row << lines[i][j]
      j += 1
    end
    matrix << row
    i += 1
  end
  matrix
end

# --------------------------
# Shape Matching Logic
# --------------------------

def shape_fits?(board, shape, start_row, start_column)
  return false if start_row + shape.length > board.length
  return false if start_column + shape[0].length > board[0].length
  true
end

def shape_matches_at?(board, shape, start_row, start_column)
  i = 0
  while i < shape.length
    j = 0
    while j < shape[i].length
      if shape[i][j] != ' '
        return false if board[start_row + i][start_column + j] != shape[i][j]
      end
      j += 1
    end
    i += 1
  end
  true
end

def find_shape(board, shape)
  row = 0
  while row < board.length
    column = 0
    while column < board[0].length
      if shape_fits?(board, shape, row, column) && shape_matches_at?(board, shape, row, column)
        puts "Found !"
        puts "Coordinates : #{column},#{row}"
        display_shape(shape, column, row, board[0].length)
        return
      end
      column += 1
    end
    row += 1
  end
  puts "Not found"
end

# --------------------------
# Display
# --------------------------

def display_shape(shape, offset_x, offset_y, board_width)
  # Top padding
  k = 0
  while k < offset_y
    puts "-" * board_width
    k += 1
  end

  # Shape lines
  i = 0
  while i < shape.length
    line = ""
    j = 0
    while j < board_width
      if j < offset_x
        line += "-"
      elsif j - offset_x < shape[i].length
        char = shape[i][j - offset_x]
        line += (char == " " ? "-" : char)
      else
        line += "-"
      end
      j += 1
    end
    puts line
    i += 1
  end
end

# --------------------------
# Program Execution
# --------------------------

def main
  return puts "Error: invalid arguments" unless validate_arguments(ARGV)

  board_lines = read_file(ARGV[0])
  shape_lines = read_file(ARGV[1])

  board = to_char_matrix(board_lines)
  shape = to_char_matrix(shape_lines)

  find_shape(board, shape)
end

main if __FILE__ == $PROGRAM_NAME
