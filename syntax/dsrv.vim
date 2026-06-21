if exists('b:current_syntax')
  finish
endif

syntax case match

syntax match dsrvLineComment "//.*$"
syntax region dsrvBlockComment start="(\*" end="\*)"

syntax region dsrvString start=+"+ skip=+\\"+ end=+"+
syntax match dsrvNumber "\v\<\d+(\.\d+)?\>"
syntax keyword dsrvBoolean true false

syntax keyword dsrvKeyword in out aux var if then else
syntax keyword dsrvType Int Float Bool Str Unit Struct List Map
syntax keyword dsrvBuiltin eval update default is_defined when latch init monitored_at dist sin cos tan abs

syntax match dsrvOperator "&&\|||\|=>\|==\|!=\|<=\|>=\|++\|[!+\-*/%=<>]"
syntax match dsrvEllipsis "\.\.\."
syntax match dsrvProperty "\v\.[A-Za-z_][A-Za-z0-9_]*"hs=s+1
syntax match dsrvField "\v\<[A-Za-z_][A-Za-z0-9_]*\ze\s*:"

highlight default link dsrvLineComment Comment
highlight default link dsrvBlockComment Comment
highlight default link dsrvString String
highlight default link dsrvNumber Number
highlight default link dsrvBoolean Boolean
highlight default link dsrvKeyword Keyword
highlight default link dsrvType Type
highlight default link dsrvBuiltin Function
highlight default link dsrvOperator Operator
highlight default link dsrvEllipsis Special
highlight default link dsrvProperty Identifier
highlight default link dsrvField Identifier

let b:current_syntax = 'dsrv'
