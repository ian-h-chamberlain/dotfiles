; extends

(
  (doc_comment) @injection.content
  ; (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "markdown_inline")
  (#set! injection.combined) ; breaks when used with #offset
  (#set! priority 110))

(
  (doc_comment) @injection.content
  ; (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "markdown")
  (#set! injection.combined)
  (#set! priority 110))

((macro_invocation
  macro: (identifier) @injection.language
  (token_tree) @injection.content)
  (#any-of? @injection.language "html" "json")
  (#set! priority 110))
