//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Thu, May 23, 2013  11:10:11 AM
// Author: hernichen

part of memcached_client;

class TextStatsOP extends TextOP implements StatsOP {
  final Completer<Map<String, String>> _cmpl; //completer to complete the future of this operation
  final Map<String, String> _stats; //stats results

  Future<Map<String, String>> get future => _cmpl.future;

  TextStatsOP(String prefix)
      : _cmpl = new Completer(),
        _stats = new HashMap() {
    _cmd = _prepareStatsCommand(prefix);
  }

  @override
  static final int VERSION_PREFIX_LEN = 'VERSION '.length;
  int handleTextCommand(String line) {
    //_logger.finest("StatsOpCommand: $this, [${line}]");
    if ("END" == line) {
      _cmpl.complete(_stats);
      return _HANDLE_COMPLETE; //complete
    } else if (line.startsWith("STAT ")) {
      final j = line.indexOf(' ', 5);
      if (j > 0) {
        final key = line.substring(5, j);
        final val = line.length > (j + 1) ? line.substring(j + 1) : null;
        if (val != null) {
          _stats[key] = val;
        }
      }
      return _HANDLE_CMD; //next command
    } else {
      OPStatus status = TextOPStatus.valueOfError(line);
      if (status != null) { //some error occur!
        _cmpl.completeError(new OPStatus.wrap(status, this));
      } else {
        //TODO: unknown protocol, try to read thru!
        _cmpl.completeError(new OPStatus.wrap(new OPStatus(OPStatus.INTERAL_ERROR.code, "PROTOCOL_ERROR 'Unknown get result format:[$line]'"), this));
      }
      return _HANDLE_COMPLETE; //complete
    }
  }

  @override
  int handleData(List<int> data) {
    throw "should never call here!";
  }

  List<int> _prepareStatsCommand(String prefix) {
    List<int> cmd = new List();

    cmd..addAll(UTF8.encode(OPType.stats.name));
    if (prefix != null) {
      cmd..add(_SPACE)
         ..addAll(UTF8.encode(prefix));
    }
    cmd..addAll(_CRLF);

    //_logger.finest("_prepareStatsCommand:[${UTF8.decode(cmd)}]\n");
    return cmd;
  }
}
