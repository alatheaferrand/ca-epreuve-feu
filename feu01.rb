# frozen_string_literal: true

# ===========================================
# Arithmetic Expression Evaluator (no native methods)
# Supports: + - * / % and parenthesis
# Input:  a string expression via ARGV[0]
# Output: result of the evaluated expression
# ===========================================

# --------------------------
# Helpers
# --------------------------

def is_digit?(character)
  character >= '0' && character <= '9'
end

def is_number_token?(token)
  return false if token.nil? || token.empty?

  start_index = 0
  start_index = 1 if token[0] == '-'

  i = start_index
  while i < token.length
    return false unless is_digit?(token[i])
    i += 1
  end
  true
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

def string_to_number(string)
  return 0 if string == "0" || string == "-0"

  i = 0
  is_negative = false

  if string[0] == '-'
    is_negative = true
    i = 1
  end

  result = 0
  while i < string.length
    digit = string[i].ord - '0'.ord
    result = result * 10 + digit
    i += 1
  end

  is_negative ? -result : result
end

def number_to_string(number)
  return "0" if number == 0

  is_negative = false
  if number < 0
    is_negative = true
    number = -number
  end

  digits = ""
  while number > 0
    digit = number % 10
    character = (digit + '0'.ord).chr

    new_digits = +character
    i = 0
    while i < digits.length
      new_digits << digits[i]
      i += 1
    end
    digits = new_digits
    number /= 10
  end

  is_negative ? "-" + digits : digits
end

# --------------------------
# Evaluators
# --------------------------

def evaluate_simple(left_operand, operator, right_operand)
  left = string_to_number(left_operand)
  right = string_to_number(right_operand)

  if (operator == '/' || operator == '%') && right == 0
    raise 'Error: division by zero'
  end

  case operator
  when '+' then left + right
  when '-' then left - right
  when '*' then left * right
  when '/' then left / right
  when '%' then left % right
  end
end

def evaluate_flat_expression(tokens)
  tokens = tokens.dup

  i = 0
  while i < tokens.length
    if get_priority(tokens[i]) == 2
      left_operand = tokens[i - 1]
      operator = tokens[i]
      right_operand = tokens[i + 1]
      result = evaluate_simple(left_operand, operator, right_operand)
      tokens[i - 1..i + 1] = [number_to_string(result)]
      i = 0
    else
      i += 1
    end
  end

  i = 0
  while i < tokens.length
    if get_priority(tokens[i]) == 1
      left_operand = tokens[i - 1]
      operator = tokens[i]
      right_operand = tokens[i + 1]
      result = evaluate_simple(left_operand, operator, right_operand)
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
      while tokens[open_index] != '('
        open_index -= 1
      end
      sub_expression = tokens[open_index + 1...i]
      result = evaluate_expression(sub_expression)
      tokens[open_index..i] = [result]
      i = open_index
    end
    i += 1
  end
  evaluate_flat_expression(tokens)
end

# --------------------------
# Tokenizer
# --------------------------

def tokenizer(expression)
  tokens = []
  token = +''
  i = 0
  while i < expression.length
    character = expression[i]

    if is_digit?(character)
      token << character
    elsif character == '-'
      if token.empty? && (tokens.empty? || tokens[-1] == '(' || get_priority(tokens[-1]) > 0)
        token << character
      else
        tokens << token unless token.empty?
        token = +''
        tokens << character
      end
    elsif character == ' '
      unless token.empty?
        tokens << token
        token = +''
      end
    elsif get_priority(character) >= 0
      tokens << token unless token.empty?
      token = +''
      tokens << character
    else
      return nil
    end

    i += 1
  end
  tokens << token unless token.empty?
  tokens
end

# --------------------------
# Input validation
# --------------------------

def valid_input?(expression)
  return false if expression == nil

  opened_parenthesis = 0
  closed_parenthesis = 0
  i = 0
  while i < expression.length
    opened_parenthesis += 1 if expression[i] == '('
    closed_parenthesis += 1 if expression[i] == ')'
    i += 1
  end
  return false if opened_parenthesis != closed_parenthesis

  i = 0
  while i < expression.length
    return true if expression[i] != ' '
    i += 1
  end
  false
end

def is_operator(token)
  token == '+' || token == '-' || token == '*' || token == '/' || token == '%'
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
      previous_token = tokens[i - 1]
      next_token = tokens[i + 1]
      return false unless is_number_token?(previous_token) || previous_token == ')'
      return false unless is_number_token?(next_token) || next_token == '(' || next_token[0] == '-'
    end
    i += 1
  end

  has_number
end

# --------------------------
# Program execution
# --------------------------

def main
  expression = ARGV[0]

  unless valid_input?(expression)
    puts "Error: invalid input"
    return
  end

  tokens = tokenizer(expression)
  if tokens == nil || !valid_token_sequence?(tokens)
    puts "Error: invalid token sequence"
    return
  end

  begin
    result = evaluate_expression(tokens)
    puts result
  rescue => error
    puts error.message
    return
  end
end

main if __FILE__ == $PROGRAM_NAME
