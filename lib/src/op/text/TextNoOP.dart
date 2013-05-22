part of memcached_client;

class TextNoOP extends TextOP implements NoOP {
  final Completer<bool> _cmpl; //completer to complete the future of this operation

  Future<bool> get future => _cmpl.future;

  TextNoOP()
      : _cmpl = new Completer() {
    _cmd = _prepareNoCommand();
  }

  //@Override
  static final int VERSION_PREFIX_LEN = 'VERSION '.length;
  int handleTextCommand(String line) {
    _logger.finest("NoOpCommand: $this, [${line}]\n");
    OPStatus status = TextOPStatus.valueOfError(line);
    if (status != null)
      _cmpl.completeError(status);
    else {
      _cmpl.complete(true);
    }
    return _HANDLE_COMPLETE;
  }

  //@Override
  int handleData(List<int> data) {
    throw "should never call here!";
  }

  List<int> _prepareNoCommand() {
    List<int> cmd = new List();

    //Use version as noop command in Text protocol
    cmd..addAll(encodeUtf8(OPType.version.name))
       ..addAll(_CRLF);

    _logger.finest("_prepareNoCommand:[${decodeUtf8(cmd)}]\n");
    return cmd;
  }

  String toString() => "NoOP: $seq";
}



