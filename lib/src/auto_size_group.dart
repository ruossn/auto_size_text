part of auto_size_text;

/// Controller to synchronize the fontSize of multiple AutoSizeTexts.
class AutoSizeGroup {
  final _listeners = <AutoSizeGroupListener, double>{};
  var _widgetsNotified = false;
  var fontSize = double.infinity;

  void register(AutoSizeGroupListener text) {
    _listeners[text] = double.infinity;
  }

  void _updateFontSize(AutoSizeGroupListener text, double maxFontSize) {
    final oldFontSize = fontSize;
    if (maxFontSize <= fontSize) {
      fontSize = maxFontSize;
      _listeners[text] = maxFontSize;
    } else if (_listeners[text] == fontSize) {
      _listeners[text] = maxFontSize;
      fontSize = double.infinity;
      for (final size in _listeners.values) {
        if (size < fontSize) fontSize = size;
      }
    } else {
      _listeners[text] = maxFontSize;
    }

    if (oldFontSize != fontSize) {
      _widgetsNotified = false;
      scheduleMicrotask(_notifyListeners);
    }
  }

  void _notifyListeners() {
    if (_widgetsNotified) {
      return;
    } else {
      _widgetsNotified = true;
    }

    for (final textState in _listeners.keys) {
      if (textState.mounted) {
        textState._notifySync();
      }
    }
  }

  void _remove(AutoSizeGroupListener text) {
    _updateFontSize(text, double.infinity);
    _listeners.remove(text);
  }
}
