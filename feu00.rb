# frozen_string_literal: true

# Warm-up
# Displays a rectangle in the terminal using two input arguments: width and height.

# -------------------------------
# Validation
# -------------------------------

def validate_arguments(arguments)
  return 'error: 2 arguments expected' unless arguments.length == 2

  arguments.each do |argument|
    return 'error: width and height must be positive integers' unless argument.match?(/^\d+$/) && argument.to_i.positive?
  end

  nil
end

# -------------------------------
# Helpers
# -------------------------------

def build_line(width)
  return 'o' if width == 1

  'o' + ('-' * (width - 2)) + 'o'
end

def build_middle(width)
  return '|' if width == 1

  '|' + (' ' * (width - 2)) + '|'
end

# -------------------------------
# Business Logic
# -------------------------------

def draw_rectangle(width, height)
  puts build_line(width)

  return if height <= 1

  (height - 2).times do
    puts build_middle(width)
  end

  puts build_line(width)
end

# -------------------------------
# Program Execution
# -------------------------------

def main
  arguments = ARGV
  error = validate_arguments(arguments)
  return puts error if error

  width = arguments[0].to_i
  height = arguments[1].to_i

  draw_rectangle(width, height)
end

main if __FILE__ == $PROGRAM_NAME
