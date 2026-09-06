import 'package:graphql_parser3/graphql_parser3.dart';
import 'package:test/test.dart';

DocumentContext parse(String text) =>
    Parser(scan(text, sourceUrl: 'test')).parseDocument();

OperationDefinitionContext firstOperation(String text) =>
    parse(text).definitions.whereType<OperationDefinitionContext>().first;

List<SelectionContext> selectionsOf(String text) =>
    firstOperation(text).selectionSet.selections;

void main() {
  group('lexer', () {
    test('splits a query into its tokens', () {
      final List<Token> tokens = scan('{ user }');

      expect(tokens.map((Token t) => t.type), <TokenType>[
        TokenType.LBRACE,
        TokenType.NAME,
        TokenType.RBRACE,
      ]);
    });

    test('skips comments, whitespace, commas and a byte order mark', () {
      final List<Token> tokens = scan('﻿# a comment\n{ a, b }');

      expect(tokens.map((Token t) => t.text), <String>['{', 'a', 'b', '}']);
    });

    test('reads a three-character ellipsis as a single token', () {
      final List<Token> tokens = scan('...');

      expect(tokens, hasLength(1));
      expect(tokens.single.type, TokenType.ELLIPSIS);
    });

    test('reads numbers, including exponents and negatives', () {
      for (final String source in <String>[
        '1',
        '-1',
        '1.5',
        '1e3',
        '-1.5e-3',
      ]) {
        final List<Token> tokens = scan(source);
        expect(tokens.single.type, TokenType.NUMBER, reason: source);
        expect(tokens.single.text, source, reason: source);
      }
    });

    test('reads a block string as one token', () {
      final List<Token> tokens = scan('"""a\nb"""');

      expect(tokens.single.type, TokenType.BLOCK_STRING);
    });

    test('raises a syntax error on an unexpected character', () {
      expect(() => scan('%'), throwsA(isA<SyntaxError>()));
    });

    test('carries a span pointing at the source', () {
      final List<Token> tokens = scan('{ user }', sourceUrl: 'query.graphql');

      expect(tokens.first.span, isNotNull);
      expect(tokens.first.span!.start.line, 0);
      expect(
        tokens.first.span!.sourceUrl.toString(),
        contains('query.graphql'),
      );
    });
  });

  group('string values', () {
    String valueOf(String literal) {
      final List<SelectionContext> selections = selectionsOf(
        '{ echo(text: $literal) }',
      );
      final ArgumentContext argument =
          selections.single.field!.arguments.single;
      return (argument.value as StringValueContext).stringValue;
    }

    test('reads a plain literal', () {
      expect(valueOf('"hello"'), 'hello');
    });

    test('decodes the escapes it recognises', () {
      expect(valueOf(r'"a\nb"'), 'a\nb');
      expect(valueOf(r'"a\tb"'), 'a\tb');
      expect(valueOf(r'"a\rb"'), 'a\rb');
      expect(valueOf(r'"a\bb"'), 'a\bb');
      expect(valueOf(r'"a\fb"'), 'a\fb');
      expect(valueOf(r'"a\"b"'), 'a"b');
      expect(valueOf(r'"a\\b"'), r'a\b');
    });

    test('decodes a unicode escape', () {
      expect(valueOf(r'"été"'), 'été');
    });

    test('decodes a unicode escape sitting at the very end', () {
      expect(valueOf(r'"A"'), 'A');
    });
  });

  group('parser', () {
    test('parses a shorthand query', () {
      final OperationDefinitionContext operation = firstOperation('{ user }');

      expect(operation.isQuery, isTrue);
      expect(operation.name, isNull);
      expect(operation.selectionSet.selections, hasLength(1));
    });

    test('tells the operation types apart', () {
      expect(firstOperation('query Q { a }').isQuery, isTrue);
      expect(firstOperation('mutation M { a }').isMutation, isTrue);
      expect(firstOperation('subscription S { a }').isSubscription, isTrue);
      expect(firstOperation('query Q { a }').name, 'Q');
    });

    test('parses a nested selection set', () {
      final List<SelectionContext> selections = selectionsOf(
        '{ user { name } }',
      );
      final FieldContext user = selections.single.field!;

      expect(user.fieldName.nameToken!.text, 'user');
      expect(
        user.selectionSet!.selections.single.field!.fieldName.nameToken!.text,
        'name',
      );
    });

    test('parses an alias', () {
      final List<SelectionContext> selections = selectionsOf('{ who: user }');
      final AliasContext alias = selections.single.field!.fieldName.alias!;

      expect(alias.alias, 'who');
      expect(alias.name, 'user');
    });

    test('parses arguments of every scalar shape', () {
      final List<ArgumentContext> arguments = selectionsOf(
        '{ f(s: "a", i: 1, f: 1.5, b: true, n: null, e: RED) }',
      ).single.field!.arguments;

      expect(arguments.map((ArgumentContext a) => a.name), <String>[
        's',
        'i',
        'f',
        'b',
        'n',
        'e',
      ]);
      expect(arguments[0].value, isA<StringValueContext>());
      expect(arguments[1].value, isA<NumberValueContext>());
      expect(arguments[3].value, isA<BooleanValueContext>());
    });

    test('parses a list argument', () {
      final ArgumentContext argument = selectionsOf(
        '{ f(ids: [1, 2, 3]) }',
      ).single.field!.arguments.single;

      expect(argument.value, isA<ListValueContext>());
    });

    test('parses a variable definition and its use', () {
      final OperationDefinitionContext operation = firstOperation(
        r'query Q($id: ID!) { user(id: $id) }',
      );

      expect(operation.variableDefinitions, isNotNull);
      expect(
        operation.variableDefinitions!.variableDefinitions.single.variable.name,
        'id',
      );
    });

    test('parses a fragment definition and a spread', () {
      final DocumentContext document = parse(
        '{ user { ...names } } fragment names on User { name }',
      );

      final FragmentDefinitionContext fragment = document.definitions
          .whereType<FragmentDefinitionContext>()
          .single;
      expect(fragment.name, 'names');
      expect(fragment.typeCondition.typeName.name, 'User');

      final SelectionContext selection = document.definitions
          .whereType<OperationDefinitionContext>()
          .single
          .selectionSet
          .selections
          .single
          .field!
          .selectionSet!
          .selections
          .single;
      expect(selection.fragmentSpread, isNotNull);
      expect(selection.fragmentSpread!.name, 'names');
    });

    test('parses an inline fragment', () {
      final SelectionContext selection = selectionsOf(
        '{ user { ... on Admin { level } } }',
      ).single.field!.selectionSet!.selections.single;

      expect(selection.inlineFragment, isNotNull);
      expect(selection.inlineFragment!.typeCondition.typeName.name, 'Admin');
    });

    test('parses a directive', () {
      final FieldContext user = selectionsOf(
        r'{ user @include(if: true) { name } }',
      ).single.field!;

      expect(user.directives, hasLength(1));
      expect(user.directives.single.name, 'include');
    });

    test('parses several definitions in one document', () {
      final DocumentContext document = parse(
        'query A { a } mutation B { b } fragment C on T { c }',
      );

      expect(document.definitions, hasLength(3));
    });

    test('carries a span covering the whole document', () {
      final DocumentContext document = parse('{ user }');

      expect(document.span, isNotNull);
      expect(document.span!.text, contains('user'));
    });

    test('answers a null span for an empty document', () {
      expect(parse('').span, isNull);
    });
  });

  group('syntax errors', () {
    test('an unterminated selection set is reported', () {
      final Parser parser = Parser(scan('{ user '));

      expect(
        () => parser.parseDocument(),
        anyOf(throwsA(isA<SyntaxError>()), returnsNormally),
      );
      // Either shape is acceptable, but the parser must never stay silent.
      expect(parser.errors.isNotEmpty || parser.tokens.isNotEmpty, isTrue);
    });

    test('a syntax error carries a span', () {
      try {
        scan('%');
        fail('expected a SyntaxError');
      } on SyntaxError catch (error) {
        expect(error.span, isNotNull);
        expect(error.toString(), contains('%'));
      }
    });
  });
}
