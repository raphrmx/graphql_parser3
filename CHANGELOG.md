# Change Log

## 3.2.1

### Changed
- `LICENSE` carries a copyright notice for the work done on this line, next to
  the upstream one it has always kept, as the BSD-3-Clause terms require.
  `AUTHORS.md` already recorded who did what; the licence file now says the same
  thing.
- The README says where to look for both, rather than describing the licence
  file as untouched.

No code changed.

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
