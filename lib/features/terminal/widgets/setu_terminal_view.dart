// ignore_for_file: implementation_imports
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';
import 'package:xterm/src/ui/custom_text_edit.dart';
import 'package:xterm/src/ui/input_map.dart';
import 'package:xterm/src/ui/keyboard_listener.dart';
import 'package:xterm/src/ui/render.dart';
import 'package:xterm/src/ui/scroll_handler.dart';
import 'package:xterm/src/ui/shortcut/actions.dart';

/// An enhanced TerminalView designed specifically for mobile software keyboards
/// (Gboard, Samsung Keyboard, SwiftKey, iOS Keyboard, etc.) with full Termius-parity Enter & action key detection.
class SetuTerminalView extends StatefulWidget {
  const SetuTerminalView(
    this.terminal, {
    super.key,
    this.controller,
    this.theme = TerminalThemes.defaultTheme,
    this.textStyle = const TerminalStyle(),
    this.textScaler,
    this.padding,
    this.scrollController,
    this.autoResize = true,
    this.backgroundOpacity = 1,
    this.focusNode,
    this.autofocus = false,
    this.onTapUp,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.mouseCursor = SystemMouseCursors.text,
    this.keyboardType = TextInputType.text,
    this.keyboardAppearance = Brightness.dark,
    this.cursorType = TerminalCursorType.block,
    this.alwaysShowCursor = false,
    this.deleteDetection = true,
    this.shortcuts,
    this.onKeyEvent,
    this.readOnly = false,
    this.hardwareKeyboardOnly = false,
    this.simulateScroll = true,
  });

  final Terminal terminal;
  final TerminalController? controller;
  final TerminalTheme theme;
  final TerminalStyle textStyle;
  final TextScaler? textScaler;
  final EdgeInsets? padding;
  final ScrollController? scrollController;
  final bool autoResize;
  final double backgroundOpacity;
  final FocusNode? focusNode;
  final bool autofocus;
  final void Function(TapUpDetails, CellOffset)? onTapUp;
  final void Function(TapDownDetails, CellOffset)? onSecondaryTapDown;
  final void Function(TapUpDetails, CellOffset)? onSecondaryTapUp;
  final MouseCursor mouseCursor;
  final TextInputType keyboardType;
  final Brightness keyboardAppearance;
  final TerminalCursorType cursorType;
  final bool alwaysShowCursor;
  final bool deleteDetection;
  final Map<ShortcutActivator, Intent>? shortcuts;
  final FocusOnKeyEventCallback? onKeyEvent;
  final bool readOnly;
  final bool hardwareKeyboardOnly;
  final bool simulateScroll;

  @override
  State<SetuTerminalView> createState() => SetuTerminalViewState();
}

class SetuTerminalViewState extends State<SetuTerminalView> {
  late FocusNode _focusNode;
  late final ShortcutManager _shortcutManager;
  final _customTextEditKey = GlobalKey<CustomTextEditState>();
  final _scrollableKey = GlobalKey<ScrollableState>();
  final _viewportKey = GlobalKey();
  String? _composingText;
  late TerminalController _controller;
  late ScrollController _scrollController;

  LongPressStartDetails? _lastLongPressStartDetails;
  DragStartDetails? _lastDragStartDetails;

  RenderTerminal get renderTerminal =>
      _viewportKey.currentContext!.findRenderObject() as RenderTerminal;

  @override
  void initState() {
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TerminalController();
    _scrollController = widget.scrollController ?? ScrollController();
    _shortcutManager = ShortcutManager(
      shortcuts: widget.shortcuts ?? defaultTerminalShortcuts,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(SetuTerminalView oldWidget) {
    if (oldWidget.focusNode != widget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
    }
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TerminalController();
    }
    if (oldWidget.scrollController != widget.scrollController) {
      if (oldWidget.scrollController == null) {
        _scrollController.dispose();
      }
      _scrollController = widget.scrollController ?? ScrollController();
    }
    _shortcutManager.shortcuts = widget.shortcuts ?? defaultTerminalShortcuts;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    _shortcutManager.dispose();
    super.dispose();
  }

  void _sendEnterKey() {
    _scrollToBottom();
    // Dispatch Enter key (Carriage Return '\r') to the shell
    widget.terminal.keyInput(TerminalKey.enter);
  }

  void _onInsert(String text) {
    if (text.isEmpty) return;

    // 1. If text is single newline or carriage return from soft keyboard, trigger Enter key!
    if (text == '\n' || text == '\r' || text == '\r\n') {
      _sendEnterKey();
      return;
    }

    // 2. If text contains embedded newlines (multiline paste/input), normalize \n to \r for PTY
    if (text.contains('\n') || text.contains('\r')) {
      final normalized = text.replaceAll('\r\n', '\r').replaceAll('\n', '\r');
      widget.terminal.textInput(normalized);
      _scrollToBottom();
      return;
    }

    // 3. Standard character / word insertion
    final key = charToTerminalKey(text.trim());
    final consumed = key == null ? false : widget.terminal.keyInput(key);

    if (!consumed) {
      widget.terminal.textInput(text);
    }

    _scrollToBottom();
  }

  void _onComposing(String? text) {
    setState(() => _composingText = text);
  }

  KeyEventResult _handleKeyEvent(FocusNode focusNode, KeyEvent event) {
    final resultOverride = widget.onKeyEvent?.call(focusNode, event);
    if (resultOverride != null && resultOverride != KeyEventResult.ignored) {
      return resultOverride;
    }

    // Intercept Enter and Numpad Enter keys explicitly for physical and virtual key events
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (event is KeyDownEvent) {
        _sendEnterKey();
        return KeyEventResult.handled;
      }
      return KeyEventResult.handled;
    }

    // ignore: invalid_use_of_protected_member
    final shortcutResult = _shortcutManager.handleKeypress(
      focusNode.context!,
      event,
    );

    if (shortcutResult != KeyEventResult.ignored) {
      return shortcutResult;
    }

    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }

    final key = keyToTerminalKey(event.logicalKey);
    if (key == null) {
      return KeyEventResult.ignored;
    }

    final handled = widget.terminal.keyInput(
      key,
      ctrl: HardwareKeyboard.instance.isControlPressed,
      alt: HardwareKeyboard.instance.isAltPressed,
      shift: HardwareKeyboard.instance.isShiftPressed,
    );

    if (handled) {
      _scrollToBottom();
    }

    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  void _onKeyboardShow() {
    if (_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _onEditableRect(Rect rect, Rect caretRect) {
    _customTextEditKey.currentState?.setEditableRect(rect, caretRect);
  }

  void _scrollToBottom() {
    final position = _scrollableKey.currentState?.position;
    if (position != null) {
      position.jumpTo(position.maxScrollExtent);
    }
  }

  void requestKeyboard() {
    _customTextEditKey.currentState?.requestKeyboard();
  }

  void closeKeyboard() {
    _customTextEditKey.currentState?.closeKeyboard();
  }

  void _handleTapDown(TapDownDetails details) {
    if (_controller.selection != null) {
      _controller.clearSelection();
    } else {
      if (!widget.hardwareKeyboardOnly) {
        _customTextEditKey.currentState?.requestKeyboard();
      } else {
        _focusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Scrollable(
      key: _scrollableKey,
      controller: _scrollController,
      viewportBuilder: (context, offset) {
        return _SetuTerminalRenderView(
          key: _viewportKey,
          terminal: widget.terminal,
          controller: _controller,
          offset: offset,
          padding: MediaQuery.of(context).padding,
          autoResize: widget.autoResize,
          textStyle: widget.textStyle,
          textScaler: widget.textScaler ?? MediaQuery.textScalerOf(context),
          theme: widget.theme,
          focusNode: _focusNode,
          cursorType: widget.cursorType,
          alwaysShowCursor: widget.alwaysShowCursor,
          onEditableRect: _onEditableRect,
          composingText: _composingText,
        );
      },
    );

    child = TerminalScrollGestureHandler(
      terminal: widget.terminal,
      simulateScroll: widget.simulateScroll,
      getCellOffset: (offset) => renderTerminal.getCellOffset(offset),
      getLineHeight: () => renderTerminal.lineHeight,
      child: child,
    );

    if (!widget.hardwareKeyboardOnly) {
      child = CustomTextEdit(
        key: _customTextEditKey,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        inputType: widget.keyboardType,
        inputAction: TextInputAction.send, // Set send/action for mobile soft keyboard
        keyboardAppearance: widget.keyboardAppearance,
        deleteDetection: widget.deleteDetection,
        onInsert: _onInsert,
        onDelete: () {
          _scrollToBottom();
          widget.terminal.keyInput(TerminalKey.backspace);
        },
        onComposing: _onComposing,
        onAction: (action) {
          // ANY soft keyboard action (Send, Go, Done, Newline, Unspecified, None) sends Enter!
          _sendEnterKey();
        },
        onKeyEvent: _handleKeyEvent,
        readOnly: widget.readOnly,
        child: child,
      );
    } else if (!widget.readOnly) {
      child = CustomKeyboardListener(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onInsert: _onInsert,
        onComposing: _onComposing,
        onKeyEvent: _handleKeyEvent,
        child: child,
      );
    }

    child = TerminalActions(
      terminal: widget.terminal,
      controller: _controller,
      child: child,
    );

    child = KeyboardVisibilty(
      onKeyboardShow: _onKeyboardShow,
      child: child,
    );

    child = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _handleTapDown,
      onTapUp: (details) {
        final offset = renderTerminal.getCellOffset(details.localPosition);
        widget.onTapUp?.call(details, offset);
      },
      onSecondaryTapDown: (details) {
        final offset = renderTerminal.getCellOffset(details.localPosition);
        widget.onSecondaryTapDown?.call(details, offset);
      },
      onSecondaryTapUp: (details) {
        final offset = renderTerminal.getCellOffset(details.localPosition);
        widget.onSecondaryTapUp?.call(details, offset);
      },
      onDoubleTapDown: (details) {
        renderTerminal.selectWord(details.localPosition);
      },
      onLongPressStart: (details) {
        _lastLongPressStartDetails = details;
        renderTerminal.selectWord(details.localPosition);
      },
      onLongPressMoveUpdate: (details) {
        if (_lastLongPressStartDetails != null) {
          renderTerminal.selectWord(
            _lastLongPressStartDetails!.localPosition,
            details.localPosition,
          );
        }
      },
      onPanStart: (details) {
        _lastDragStartDetails = DragStartDetails(
          localPosition: details.localPosition,
          globalPosition: details.globalPosition,
          kind: details.kind,
        );
        details.kind == PointerDeviceKind.mouse
            ? renderTerminal.selectCharacters(details.localPosition)
            : renderTerminal.selectWord(details.localPosition);
      },
      onPanUpdate: (details) {
        if (_lastDragStartDetails != null) {
          renderTerminal.selectCharacters(
            _lastDragStartDetails!.localPosition,
            details.localPosition,
          );
        }
      },
      child: child,
    );

    child = MouseRegion(
      cursor: widget.mouseCursor,
      child: child,
    );

    child = Container(
      color: widget.theme.background.withValues(alpha: widget.backgroundOpacity),
      padding: widget.padding,
      child: child,
    );

    return child;
  }
}

class _SetuTerminalRenderView extends LeafRenderObjectWidget {
  const _SetuTerminalRenderView({
    super.key,
    required this.terminal,
    required this.controller,
    required this.offset,
    required this.padding,
    required this.autoResize,
    required this.textStyle,
    required this.textScaler,
    required this.theme,
    required this.focusNode,
    required this.cursorType,
    required this.alwaysShowCursor,
    this.onEditableRect,
    this.composingText,
  });

  final Terminal terminal;
  final TerminalController controller;
  final ViewportOffset offset;
  final EdgeInsets padding;
  final bool autoResize;
  final TerminalStyle textStyle;
  final TextScaler textScaler;
  final TerminalTheme theme;
  final FocusNode focusNode;
  final TerminalCursorType cursorType;
  final bool alwaysShowCursor;
  final EditableRectCallback? onEditableRect;
  final String? composingText;

  @override
  RenderTerminal createRenderObject(BuildContext context) {
    return RenderTerminal(
      terminal: terminal,
      controller: controller,
      offset: offset,
      padding: padding,
      autoResize: autoResize,
      textStyle: textStyle,
      textScaler: textScaler,
      theme: theme,
      focusNode: focusNode,
      cursorType: cursorType,
      alwaysShowCursor: alwaysShowCursor,
      onEditableRect: onEditableRect,
      composingText: composingText,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTerminal renderObject) {
    renderObject
      ..terminal = terminal
      ..controller = controller
      ..offset = offset
      ..padding = padding
      ..autoResize = autoResize
      ..textStyle = textStyle
      ..textScaler = textScaler
      ..theme = theme
      ..focusNode = focusNode
      ..cursorType = cursorType
      ..alwaysShowCursor = alwaysShowCursor
      ..onEditableRect = onEditableRect
      ..composingText = composingText;
  }
}
