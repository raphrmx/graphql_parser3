# Change Log

## 3.1.0

### Removed
- The `charcode` dependency. It supplied the escape-sequence code units of the
  string literal decoder and nothing else, so those are now named constants in
  the file that reads them. `source_span` and `string_scanner` stay: the lexer
  is built on `SpanScanner` and every AST node carries a span.

### Added
- `DirectiveContext.name`, matching the accessor every sibling node already
  offers.
- A test suite. There was none, although `test` was already declared.

## 3.0.0

* Initial release
