# frozen_string_literal: true

# ===========================================
# Arithmetic Expression Evaluator (no native methods)
# Supports: + - * / % and parenthesis
# Input:  a string expression via ARGV[0]
# Output: result of the evaluated expression
# ===========================================

# --------------------------
# Argument & Input Handling
# --------------------------

def validate_arguments(arguments)
  return false unless arguments.length == 1
  true
end

def read_expression(arguments)
  arguments[0]
end

# --------------------------
# Tokenizer
# --------------------------

def is_digit?(char)
  char >= '0' && char <= '9'
end

def get_priority(operator)
  case operator
  when '*', '/', '%'
    2
  when '+', '-'
    1
  when '(', ')'
    0
  else
    -1
  end
end

def tokenizer(expression)
  tokens = []
  token = +''
  i = 0

  while i < expression.length
    char = expression[i]

    if is_digit?(char)
      token << char
    elsif char == '-'
      if token.empty? && (tokens.empty? || tokens[-1] == '(' || get_priority(tokens[-1]) > 0)
        token << char
      else
        tokens << token unless token.empty?
        token = +''
        tokens << char
      end
    elsif char == ' '
      unless token.empty?
        tokens << token
        token = +''
      end
    elsif get_priority(char) >= 0
      tokens << token unless token.empty?
      token = +''
      tokens << char
    else
      return nil
    end

    i += 1
  end

  tokens << token unless token.empty?
  tokens
end

# --------------------------
# Helpers
# --------------------------

def is_number_token?(token)
  return false if token.nil? || token.empty?
  start_index = (token[0] == '-') ? 1 : 0

  i = start_index
  while i < token.length
    return false unless is_digit?(token[i])
    i += 1
  end
  true
end

def string_to_number(str)
  return 0 if str == "0" || str == "-0"

  i = 0
  is_negative = false
  is_negative = true if str[0] == '-'
  i += 1 if is_negative

  result = 0
  while i < str.length
    digit = str[i].ord - '0'.ord
    result = result * 10 + digit
    i += 1
  end

  is_negative ? -result : result
end

def number_to_string(number)
  return "0" if number == 0

  is_negative = false
  is_negative = true if number < 0
  number = -number if is_negative

  digits = ''
  while number > 0
    digit = number % 10
    digits = (digit + '0'.ord).chr + digits
    number /= 10
  end

  is_negative ? '-' + digits : digits
end

def is_operator(token)
  ['+', '-', '*', '/', '%'].include?(token)
end

# --------------------------
# Input Validation
# --------------------------

def valid_input?(expression)
  return false if expression.nil?

  opened = 0
  closed = 0
  i = 0
  while i < expression.length
    opened += 1 if expression[i] == '('
    closed += 1 if expression[i] == ')'
    i += 1
  end
  return false if opened != closed

  i = 0
  while i < expression.length
    return true if expression[i] != ' '
    i += 1
  end

  false
end

def valid_token_sequence?(tokens)
  return false unless is_number_token?(tokens[0]) || tokens[0] == '(' || (tokens[0][0] == '-' && is_number_token?(tokens[0]))
  return false unless is_number_token?(tokens[-1]) || tokens[-1] == ')'

  has_number = false
  i = 0
  while i < tokens.length
    token = tokens[i]
    has_number = true if is_number_token?(token)

    if is_operator(token)
      return false if i == 0 || i == tokens.length - 1
      prev = tokens[i - 1]
      nxt = tokens[i + 1]
      return false unless is_number_token?(prev) || prev == ')'
      return false unless is_number_token?(nxt) || nxt == '(' || nxt[0] == '-'
    end

    i += 1
  end

  has_number
end

# --------------------------
# Evaluators
# --------------------------

def evaluate_simple(left, operator, right)
  a = string_to_number(left)
  b = string_to_number(right)

  raise 'Error: division by zero' if (operator == '/' || operator == '%') && b == 0

  case operator
  when '+' then a + b
  when '-' then a - b
  when '*' then a * b
  when '/' then a / b
  when '%' then a % b
  end
end

def evaluate_flat_expression(tokens)
  tokens = tokens.dup

  # Priority 2: *, /, %
  i = 0
  while i < tokens.length
    if get_priority(tokens[i]) == 2
      result = evaluate_simple(tokens[i - 1], tokens[i], tokens[i + 1])
      tokens[i - 1..i + 1] = [number_to_string(result)]
      i = 0
    else
      i += 1
    end
  end

  # Priority 1: +, -
  i = 0
  while i < tokens.length
    if get_priority(tokens[i]) == 1
      result = evaluate_simple(tokens[i - 1], tokens[i], tokens[i + 1])
      tokens[i - 1..i + 1] = [number_to_string(result)]
      i = 0
    else
      i += 1
    end
  end

  tokens[0]
end

def evaluate_expression(tokens)
  i = 0
  while i < tokens.length
    if tokens[i] == ')'
      open_index = i - 1
      open_index -= 1 while tokens[open_index] != '('
      inner = tokens[open_index + 1...i]
      result = evaluate_expression(inner)
      tokens[open_index..i] = [result]
      i = open_index
    end
    i += 1
  end

  evaluate_flat_expression(tokens)
end

# --------------------------
# Program Execution
# --------------------------

def main
  unless validate_arguments(ARGV)
    puts 'error: 1 argument expected'
    return
  end

  expression = read_expression(ARGV)

  unless valid_input?(expression)
    puts 'error: invalid expression format'
    return
  end

  tokens = tokenizer(expression)

  if tokens.nil? || !valid_token_sequence?(tokens)
    puts 'error: invalid token sequence'
    return
  end

  begin
    result = evaluate_expression(tokens)
    puts result
  rescue => e
    puts "error: #{e.message}"
  end
end

main if __FILE__ == $PROGRAM_NAME
