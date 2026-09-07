# Change Log

## 3.2.0

First release published to pub.dev. The package was consumed straight from its
git repository until now; nothing about the code changed.

### Added
- `example/main.dart`: parses a query, reads its operation and its fragment, and
  shows the span every node carries.
- Package metadata for pub.dev: a description that says what the package does
  rather than what to use instead, an issue tracker, and topics.

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
