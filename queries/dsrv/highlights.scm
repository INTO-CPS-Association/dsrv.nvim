(line_comment) @comment

(string) @string
(number) @number
(boolean) @boolean
(builtin_type) @type.builtin

(struct_type
  "Struct" @type.builtin)

(generic_type
  ["List" "Map"] @type.builtin)

(generic_type
  constructor: (identifier) @type)

[
  "in"
  "out"
  "aux"
  "var"
  "if"
  "then"
  "else"
] @keyword

[
  "&&"
  "||"
  "!"
  "=>"
  "=="
  "!="
  "<="
  ">="
  "+"
  "-"
  "*"
  "/"
  "%"
  "="
  "++"
] @operator

(binary_expression
  ["<" ">"] @operator)

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

(struct_type
  ["<" ">"] @punctuation.bracket)

(generic_type
  ["<" ">"] @punctuation.bracket)

[
  ","
  ":"
  "."
] @punctuation.delimiter

(ellipsis) @punctuation.special

((identifier) @type.builtin
  (#match? @type.builtin "^(Int|Float|Bool|Str|Unit|List|Map|Struct)$"))

((identifier) @keyword
  (#match? @keyword "^(dynamic|defer)$"))

((identifier) @function.builtin
  (#match? @function.builtin "^(eval|update|default|is_defined|when|latch|init|monitored_at|dist|sin|cos|tan|abs)$"))

(declaration
  name: (identifier) @variable)

(struct_field_type
  name: (identifier) @property)

(object_entry
  key: (identifier) @property)

(assignment
  left: (identifier) @variable)

(call_expression
  function: (identifier) @function)

(call_expression
  function: (member_expression
    property: (identifier) @function.method))

(member_expression
  property: (identifier) @property)
