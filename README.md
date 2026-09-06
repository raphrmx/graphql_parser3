# GraphQL Parser 3

[![Build](https://img.shields.io/github/actions/workflow/status/raphrmx/graphql_parser3/ci.yml?branch=main&label=build)](https://github.com/raphrmx/graphql_parser3/actions/workflows/ci.yml)
[![Maintainer](https://img.shields.io/badge/Maintainer-Raphael-purple)](https://comapps.be)
[![License](https://img.shields.io/badge/Licence-BSD--3--Clause-blue)](LICENSE)

Parses GraphQL queries and schemas.

*This library is merely a parser/visitor*. Any sort of actual GraphQL API functionality must be implemented by you,
or by a third-party package.

## Installation

These packages are not published on pub.dev. Depend on the repository:

```yaml
dependencies:
  graphql_parser3:
    git: https://github.com/raphrmx/graphql_parser3.git
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
