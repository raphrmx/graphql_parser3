import 'package:graphql_parser3/graphql_parser3.dart';

/// Parses a query and walks the selections of its single operation.
void main() {
  const query = r'''
query Profile($id: ID!) {
  user(id: $id) {
    name
    ...contact
  }
}

fragment contact on User {
  email
}
''';

  final document = Parser(
    scan(query, sourceUrl: 'profile.graphql'),
  ).parseDocument();

  final operation = document.definitions
      .whereType<OperationDefinitionContext>()
      .single;

  print('operation: ${operation.name}'); // Profile
  print('is a query: ${operation.isQuery}'); // true

  for (final selection in operation.selectionSet.selections) {
    final field = selection.field;
    if (field == null) continue;

    // Every node carries the span it was read from, so an error can point at
    // the source rather than describe it.
    print('${field.fieldName.name} at line ${field.span?.start.line}');
  }

  final fragment = document.definitions
      .whereType<FragmentDefinitionContext>()
      .single;

  print('fragment ${fragment.name} on ${fragment.typeCondition.typeName.name}');
}
