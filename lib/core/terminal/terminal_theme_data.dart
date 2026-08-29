import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

class SetuTerminalTheme {
  final String id;
  final String name;
  final Color background;
  final Color foreground;
  final Color cursor;
  final Color selection;
  final Color black;
  final Color red;
  final Color green;
  final Color yellow;
  final Color blue;
  final Color magenta;
  final Color cyan;
  final Color white;
  final Color brightBlack;
  final Color brightRed;
  final Color brightGreen;
  final Color brightYellow;
  final Color brightBlue;
  final Color brightMagenta;
  final Color brightCyan;
  final Color brightWhite;

  const SetuTerminalTheme({
    required this.id,
    required this.name,
    required this.background,
    required this.foreground,
    required this.cursor,
    required this.selection,
    required this.black,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.magenta,
    required this.cyan,
    required this.white,
    required this.brightBlack,
    required this.brightRed,
    required this.brightGreen,
    required this.brightYellow,
    required this.brightBlue,
    required this.brightMagenta,
    required this.brightCyan,
    required this.brightWhite,
  });

  TerminalTheme toTerminalTheme() {
    return TerminalTheme(
      cursor: cursor,
      selection: selection,
      foreground: foreground,
      background: background,
      black: black,
      red: red,
      green: green,
      yellow: yellow,
      blue: blue,
      magenta: magenta,
      cyan: cyan,
      white: white,
      brightBlack: brightBlack,
      brightRed: brightRed,
      brightGreen: brightGreen,
      brightYellow: brightYellow,
      brightBlue: brightBlue,
      brightMagenta: brightMagenta,
      brightCyan: brightCyan,
      brightWhite: brightWhite,
      searchHitBackground: const Color(0xFF388BFD).withValues(alpha: 0.4),
      searchHitBackgroundCurrent: const Color(0xFFE3B341),
      searchHitForeground: const Color(0xFF0D1117),
    );
  }

  // 1. On|Bed Dark (GitHub Dark Default)
  static const setuDark = SetuTerminalTheme(
    id: 'setu-dark',
    name: 'On|Bed Dark',
    background: Color(0xFF0D1117),
    foreground: Color(0xFFE6EDF3),
    cursor: Color(0xFF58A6FF),
    selection: Color(0xFF264F78),
    black: Color(0xFF484F58),
    red: Color(0xFFFF7B72),
    green: Color(0xFF3FB950),
    yellow: Color(0xFFD29922),
    blue: Color(0xFF58A6FF),
    magenta: Color(0xFFBC8CFF),
    cyan: Color(0xFF39C5CF),
    white: Color(0xFFB1BAC4),
    brightBlack: Color(0xFF6E7681),
    brightRed: Color(0xFFFFA198),
    brightGreen: Color(0xFF56D364),
    brightYellow: Color(0xFFE3B341),
    brightBlue: Color(0xFF79C0FF),
    brightMagenta: Color(0xFFD2A8FF),
    brightCyan: Color(0xFF56D4DD),
    brightWhite: Color(0xFFF0F6FC),
  );

  // 2. Dracula
  static const dracula = SetuTerminalTheme(
    id: 'dracula',
    name: 'Dracula',
    background: Color(0xFF282A36),
    foreground: Color(0xFFF8F8F2),
    cursor: Color(0xFFF8F8F0),
    selection: Color(0xFF44475A),
    black: Color(0xFF000000),
    red: Color(0xFFFF5555),
    green: Color(0xFF50FA7B),
    yellow: Color(0xFFF1FA8C),
    blue: Color(0xFFBD93F9),
    magenta: Color(0xFFFF79C6),
    cyan: Color(0xFF8BE9FD),
    white: Color(0xFFBFBFBF),
    brightBlack: Color(0xFF4D4D4D),
    brightRed: Color(0xFFFF6E6E),
    brightGreen: Color(0xFF69FF94),
    brightYellow: Color(0xFFFFFFA5),
    brightBlue: Color(0xFFD6ACFF),
    brightMagenta: Color(0xFFFF92DF),
    brightCyan: Color(0xFFA4FFFF),
    brightWhite: Color(0xFFE6E6E6),
  );

  // 3. Tokyo Night
  static const tokyoNight = SetuTerminalTheme(
    id: 'tokyo-night',
    name: 'Tokyo Night',
    background: Color(0xFF1A1B26),
    foreground: Color(0xFFA9B1D6),
    cursor: Color(0xFFC0CAF5),
    selection: Color(0xFF283457),
    black: Color(0xFF32344A),
    red: Color(0xFFF7768E),
    green: Color(0xFF9ECE6A),
    yellow: Color(0xFFE0AF68),
    blue: Color(0xFF7AA2F7),
    magenta: Color(0xFFAD8EE6),
    cyan: Color(0xFF449DAB),
    white: Color(0xFF787C99),
    brightBlack: Color(0xFF444B6A),
    brightRed: Color(0xFFFF7A93),
    brightGreen: Color(0xFFB9F27C),
    brightYellow: Color(0xFFFF9E64),
    brightBlue: Color(0xFF7DA6FF),
    brightMagenta: Color(0xFFBB9AF7),
    brightCyan: Color(0xFF0DB9D7),
    brightWhite: Color(0xFFACB0D0),
  );

  // 4. Nord
  static const nord = SetuTerminalTheme(
    id: 'nord',
    name: 'Nord Arctic',
    background: Color(0xFF2E3440),
    foreground: Color(0xFFD8DEE9),
    cursor: Color(0xFFD8DEE9),
    selection: Color(0xFF434C5E),
    black: Color(0xFF3B4252),
    red: Color(0xFFBF616A),
    green: Color(0xFFA3BE8C),
    yellow: Color(0xFFEBCB8B),
    blue: Color(0xFF81A1C1),
    magenta: Color(0xFFB48EAD),
    cyan: Color(0xFF88C0D0),
    white: Color(0xFFE5E9F0),
    brightBlack: Color(0xFF4C566A),
    brightRed: Color(0xFFD08770),
    brightGreen: Color(0xFFA3BE8C),
    brightYellow: Color(0xFFEBCB8B),
    brightBlue: Color(0xFF88C0D0),
    brightMagenta: Color(0xFFB48EAD),
    brightCyan: Color(0xFF8FBCBB),
    brightWhite: Color(0xFFECEFF4),
  );

  // 5. One Dark
  static const oneDark = SetuTerminalTheme(
    id: 'one-dark',
    name: 'One Dark',
    background: Color(0xFF282C34),
    foreground: Color(0xFFABB2BF),
    cursor: Color(0xFF528BFF),
    selection: Color(0xFF3E4451),
    black: Color(0xFF1E2127),
    red: Color(0xFFE06C75),
    green: Color(0xFF98C379),
    yellow: Color(0xFFD19A66),
    blue: Color(0xFF61AFEF),
    magenta: Color(0xFFC678DD),
    cyan: Color(0xFF56B6C2),
    white: Color(0xFFABB2BF),
    brightBlack: Color(0xFF5C6370),
    brightRed: Color(0xFFBE5046),
    brightGreen: Color(0xFF98C379),
    brightYellow: Color(0xFFE5C07B),
    brightBlue: Color(0xFF61AFEF),
    brightMagenta: Color(0xFFC678DD),
    brightCyan: Color(0xFF56B6C2),
    brightWhite: Color(0xFFFFFFFF),
  );

  // 6. Monokai Pro
  static const monokaiPro = SetuTerminalTheme(
    id: 'monokai-pro',
    name: 'Monokai Pro',
    background: Color(0xFF2D2A2E),
    foreground: Color(0xFFFCFCFA),
    cursor: Color(0xFFFFD866),
    selection: Color(0xFF403E41),
    black: Color(0xFF403E41),
    red: Color(0xFFFF6188),
    green: Color(0xFFA9DC76),
    yellow: Color(0xFFFFD866),
    blue: Color(0xFFFC9867),
    magenta: Color(0xFFAB9DF2),
    cyan: Color(0xFF78DCE8),
    white: Color(0xFFFCFCFA),
    brightBlack: Color(0xFF727072),
    brightRed: Color(0xFFFF6188),
    brightGreen: Color(0xFFA9DC76),
    brightYellow: Color(0xFFFFD866),
    brightBlue: Color(0xFFFC9867),
    brightMagenta: Color(0xFFAB9DF2),
    brightCyan: Color(0xFF78DCE8),
    brightWhite: Color(0xFFFCFCFA),
  );

  // 7. Solarized Dark
  static const solarizedDark = SetuTerminalTheme(
    id: 'solarized-dark',
    name: 'Solarized Dark',
    background: Color(0xFF002B36),
    foreground: Color(0xFF839496),
    cursor: Color(0xFF93A1A1),
    selection: Color(0xFF073642),
    black: Color(0xFF073642),
    red: Color(0xFFDC322F),
    green: Color(0xFF859900),
    yellow: Color(0xFFB58900),
    blue: Color(0xFF268BD2),
    magenta: Color(0xFFD33682),
    cyan: Color(0xFF2AA198),
    white: Color(0xFFEEE8D5),
    brightBlack: Color(0xFF002B36),
    brightRed: Color(0xFFCB4B16),
    brightGreen: Color(0xFF586E75),
    brightYellow: Color(0xFF657B83),
    brightBlue: Color(0xFF839496),
    brightMagenta: Color(0xFF6C71C4),
    brightCyan: Color(0xFF93A1A1),
    brightWhite: Color(0xFFFDF6E3),
  );

  // 8. OLED Black
  static const oledBlack = SetuTerminalTheme(
    id: 'oled-black',
    name: 'OLED Pure Black',
    background: Color(0xFF000000),
    foreground: Color(0xFFF0F6FC),
    cursor: Color(0xFF58A6FF),
    selection: Color(0xFF1F242C),
    black: Color(0xFF2B313A),
    red: Color(0xFFFF7B72),
    green: Color(0xFF3FB950),
    yellow: Color(0xFFD29922),
    blue: Color(0xFF58A6FF),
    magenta: Color(0xFFBC8CFF),
    cyan: Color(0xFF39C5CF),
    white: Color(0xFFB1BAC4),
    brightBlack: Color(0xFF484F58),
    brightRed: Color(0xFFFFA198),
    brightGreen: Color(0xFF56D364),
    brightYellow: Color(0xFFE3B341),
    brightBlue: Color(0xFF79C0FF),
    brightMagenta: Color(0xFFD2A8FF),
    brightCyan: Color(0xFF56D4DD),
    brightWhite: Color(0xFFFFFFFF),
  );

  static const List<SetuTerminalTheme> allThemes = [
    setuDark,
    dracula,
    tokyoNight,
    nord,
    oneDark,
    monokaiPro,
    solarizedDark,
    oledBlack,
  ];

  static SetuTerminalTheme fromId(String? id) {
    if (id == null) return setuDark;
    return allThemes.firstWhere(
      (t) => t.id == id,
      orElse: () => setuDark,
    );
  }
}
