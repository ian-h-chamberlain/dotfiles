; extends

(
  (doc_comment) @injection.content
  (#set! injection.language "markdown_inline")
  (#set! injection.combined)
)

(
  (doc_comment) @injection.content
  (#set! injection.language "markdown")
  ; (#set! injection.combined)
  (#set! priority 110)
)

((macro_invocation
  macro: (identifier) @injection.language
  (token_tree) @injection.content)
  (#any-of? @injection.language "html" "json"))
