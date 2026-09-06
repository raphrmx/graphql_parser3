import 'package:source_span/source_span.dart';

import '../syntax_error.dart';
import '../token.dart';
import 'input_value.dart';

/// Code units the escape sequences of a string literal are built from.
const int _backslash = 0x5C;
const int _lowerB = 0x62;
const int _lowerF = 0x66;
const int _lowerN = 0x6E;
const int _lowerR = 0x72;
const int _lowerT = 0x74;
const int _lowerU = 0x75;

/// Code units the recognised escapes stand for.
const int _tab = 0x09;
const int _lineFeed = 0x0A;
const int _carriageReturn = 0x0D;

/// A GraphQL string value literal.
class StringValueContext extends InputValueContext<String> {
  /// The source token.
  final Token stringToken;

  /// Whether this is a block string.
  final bool isBlockString;

  StringValueContext(this.stringToken, {this.isBlockString = false});

  @override
  FileSpan? get span => stringToken.span;

  /// The [String] value of the [stringToken].
  String get stringValue {
    String text;

    if (!isBlockString) {
      text = stringToken.text.substring(1, stringToken.text.length - 1);
    } else {
      text = stringToken.text.substring(3, stringToken.text.length - 3).trim();
    }

    var codeUnits = text.codeUnits;
    var buf = StringBuffer();

    for (var i = 0; i < codeUnits.length; i++) {
      var ch = codeUnits[i];

      if (ch == _backslash) {
        if (i < codeUnits.length - 5 && codeUnits[i + 1] == _lowerU) {
          var c1 = codeUnits[i += 2],
              c2 = codeUnits[++i],
              c3 = codeUnits[++i],
              c4 = codeUnits[++i];
          var hexString = String.fromCharCodes([c1, c2, c3, c4]);
          var hexNumber = int.parse(hexString, radix: 16);
          buf.write(String.fromCharCode(hexNumber));
          continue;
        }

        if (i < codeUnits.length - 1) {
          var next = codeUnits[++i];

          switch (next) {
            case _lowerB:
              buf.write('\b');
              break;
            case _lowerF:
              buf.write('\f');
              break;
            case _lowerN:
              buf.writeCharCode(_lineFeed);
              break;
            case _lowerR:
              buf.writeCharCode(_carriageReturn);
              break;
            case _lowerT:
              buf.writeCharCode(_tab);
              break;
            default:
              buf.writeCharCode(next);
          }
        } else {
          throw SyntaxError('Unexpected "\\" in string literal.', span);
        }
      } else {
        buf.writeCharCode(ch);
      }
    }

    return buf.toString();
  }

  @override
  String computeValue(Map<String, dynamic> variables) => stringValue;
}
