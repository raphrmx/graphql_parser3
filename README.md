# GraphQL Parser 3

[![Build](https://img.shields.io/github/actions/workflow/status/raphrmx/graphql_parser3/ci.yml?branch=main&label=build)](https://github.com/raphrmx/graphql_parser3/actions/workflows/ci.yml)
[![Pub Version](https://img.shields.io/pub/v/graphql_parser3?color=blue)](https://pub.dev/packages/graphql_parser3)
[![Maintainer](https://img.shields.io/badge/Maintainer-Raphael-purple)](https://comapps.be)
[![License](https://img.shields.io/badge/Licence-BSD--3--Clause-blue)](LICENSE)

Parses GraphQL queries and schemas.

*This library is merely a parser/visitor*. Any sort of actual GraphQL API functionality must be implemented by you,
or by a third-party package.

## Where this comes from

This package is a fork of the GraphQL stack maintained as part of
[Angel3](https://github.com/dukefirehawk/angel), which itself descends from the
`graphql_*` packages Tobe O wrote for Angel. The fork is taken from the `2`
line; the original BSD-3-Clause licence and its copyright notice are kept
verbatim in [LICENSE](LICENSE), and the bulk of the type system, the parser and
the execution algorithm are still that work.

Why fork at all. Two reasons, and only the second one still holds:

- Upstream had stopped moving while the projects depending on it had not.
  Development there has since resumed, but by then the two lines had diverged
  far enough that merging back would cost more than it returns.
- The stack was pinned to `angel3_*`, and `angel3_*` decided which `analyzer`
  and which Dart SDK everything downstream could use. That is what held the
  generator seven `analyzer` majors back for months. Cutting the tie was the
  point of the `3` line.

So: the `3` line does not track upstream and does not merge from it. It is
maintained on its own, with three rules - as few dependencies as possible, no
dependency that dictates the SDK, and no behaviour without a test covering it.

### The `3` is a lineage marker, not a version and not a succession

`graphql_parser2` is not this package's predecessor. It is its sibling, and it is
alive: 7.0.0 as of August 2026, published by dukefirehawk.com, on its own
numbering that long ago stopped matching the `2` in its name. The `3` here says
only which line this fork was taken from.

If you want the upstream package, take
[`graphql_parser2`](https://pub.dev/packages/graphql_parser2). Take this one for
the smaller dependency tree and the fixes listed below. They have not been
offered upstream. The two lines were compared at upstream 7.0.0: every release
it has cut since the fork point raises the Dart SDK floor or the linter, and its
dependency set is unchanged.

## What version 3 changed

Two dependencies, `source_span` and `string_scanner`, and nothing else. The
lexer is built on `SpanScanner` and every AST node carries a span, so both earn
their place.

- `charcode` removed. It supplied the escape-sequence code units of the string
  literal decoder and nothing else; those are named constants in the file that
  reads them.
- `DirectiveContext.name` added, matching the accessor every sibling node
  already offered. `graphql_server3` needed it to match a directive by name.
- A test suite: 26 tests over the lexer, the parser, string escapes, spans and
  syntax errors. There were none, although `test` was already declared.

The full list is in [CHANGELOG.md](CHANGELOG.md).

## Installation

```bash
dart pub add graphql_parser3
```

## Usage

The AST featured in this library was originally directly based off this ANTLR4 grammar created by Joseph T. McBride:
<https://github.com/antlr/grammars-v4/blob/master/graphql/GraphQL.g4>

It has since been updated to reflect upon the grammar in the official GraphQL
specification ([June 2018](https://facebook.github.io/graphql/June2018/)).

```dart
import 'package:graphql_parser3/graphql_parser3.dart';

doSomething(String text) {
  var tokens = scan(text);
  var parser = Parser(tokens);
  
  if (parser.errors.isNotEmpty) {
    // Handle errors...
  }
  
  // Parse the GraphQL document using recursive descent
  var doc = parser.parseDocument();
  
  // Do something with the parsed GraphQL document...
}
```
