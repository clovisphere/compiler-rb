# frozen_string_literal: true

# Transpile and test 😎
RUNTIME = 'const add = (x,y) => x + y;'
TEST = 'console.log(f(1, 2));'

# Lexical analysis 🧐
Token = Data.define(:type, :value)

# Syntax tree 🤩
CallNode = Data.define(:name, :arg_exprs)
DefNode = Data.define(:name, :arg_names, :body)
IntegerNode = Data.define(:value)
VarRefNode = Data.define(:value)

# Tokenizer class
class Tokenizer
  TOKEN_TYPES = [
    [:def, /\bdef\b/],
    [:end, /\bend\b/],
    [:identifier, /\b[a-zA-Z]+\b/],
    [:integer, /\b[0-9]+\b/],
    [:oparen, /\(/],
    [:cparen, /\)/],
    [:comma, /,/]
  ].freeze

  def initialize(code)
    @code = code
  end

  def tokenize
    tokens = []
    until @code.empty?
      tokens << tokenize_one_token
      @code = @code.strip
    end
    tokens
  end

  private

  def tokenize_one_token
    TOKEN_TYPES.each do |type, re|
      re = /\A(#{re})/
      next unless @code =~ re

      value = ::Regexp.last_match(1)
      @code = @code[value.length..]
      return Token.new(type, value)
    end
  end
end

# Parser class
class Parser
  def initialize(tokens)
    @tokens = tokens
  end

  def parse = parse_def

  private

  def consume(expected_type)
    token = @tokens.shift
    unless token.type == expected_type
      raise "Expected token type #{expected_type.inspect} but got #{token.type.inspect}"
    end

    token
  end

  def parse_arg_names
    arg_names = []
    consume(:oparen)
    arg_names << consume(:identifier).value if peek(:identifier)
    while peek(:comma)
      consume(:comma)
      arg_names << consume(:identifier).value
    end
    consume(:cparen)

    arg_names
  end

  def parse_arg_exprs
    arg_exprs = []
    consume(:oparen)
    arg_exprs << parse_expr unless peek(:cparen)
    while peek(:comma)
      consume(:comma)
      arg_exprs << parse_expr
    end
    consume(:cparen)

    arg_exprs
  end

  def parse_call
    name = consume(:identifier).value
    arg_exprs = parse_arg_exprs
    CallNode.new(name, arg_exprs)
  end

  def parse_def
    consume(:def)
    name = consume(:identifier).value
    arg_names = parse_arg_names
    body = parse_expr
    consume(:end)
    DefNode.new(name, arg_names, body)
  end

  def parse_expr
    if peek(:integer)
      parse_integer
    elsif peek(:identifier) && peek(:oparen, 1)
      parse_call
    else
      parse_var_ref
    end
  end

  def parse_integer = IntegerNode.new(consume(:integer).value.to_i)

  def parse_var_ref
    VarRefNode.new(consume(:identifier).value)
  end

  def peek(expected_type, offset = 0) = @tokens.fetch(offset).type == expected_type
end

# Generator class
class Generator
  def generate(node)
    case node
    when DefNode
      "const #{node.name} = (#{node.arg_names.join(',')}) => #{generate(node.body)};"
    when CallNode
      "#{node.name}(#{node.arg_exprs.map { |expr| generate(expr) }.join(',')})"
    when VarRefNode, IntegerNode
      node.value
    else
      raise "Unexpected node type: #{node.class}"
    end
  end
end

# The fun starts here :-)
tokens = Tokenizer.new(File.read('example')).tokenize
tree = Parser.new(tokens).parse
generated = Generator.new.generate(tree)
puts [RUNTIME, generated, TEST].join("\n")
