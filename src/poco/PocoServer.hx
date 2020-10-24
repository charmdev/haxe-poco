package poco;

import sys.net.Host;
import haxe.CallStack;
import haxe.Json;
import sys.net.Socket;
import haxe.io.Bytes;
import haxe.io.Bytes;
import haxe.io.Error;
import haxe.Timer;
import poco.Protocol;
import cpp.vm.Thread;

interface IRpc {
  function dump():DumpResponse;
}

class Handler {
  var socket:Socket;
  var rpc:IRpc;

  public function new(socket:Socket, rpc:IRpc) {
    this.socket = socket;
    this.rpc = rpc;
  }

  public function update():Bool {
    var needClose = false;
    try {
      var input = socket.input;
      var output = socket.output;
      var length:Int = input.readInt32();
      if (length > 0) {
        var s:String = input.readString(length);
        var request:RequestMessage = haxe.Json.parse(s);
        var response:ResponseMessage = handleRequest(request);
        var serialized:String = haxe.Json.stringify(response);
        //trace('request: $s');
        //trace('response: $serialized');
        output.writeInt32(serialized.length);
        output.writeString(serialized);
      }
    } catch (e:Dynamic) {
      needClose = true;
      if (needClose) trace('closing because of: $e');
    }
    return needClose;
  }

  private function handleRequest(request:RequestMessage):ResponseMessage {
    var response:ResponseMessage = {
      id:request.id,
      jsonrpc:request.jsonrpc,
      result:null,
      error:null
    }
    try {
      switch (request.method.toLowerCase()) {
        case "dump":
          response.result = callOnMainThread(rpc.dump);
        default:
          response.error = "rpc method not found";
      }
    }
    catch(e:Dynamic) {
      response.error = '$e';
    }
    return response;
  }

  private function callOnMainThread<T>(handler:Void->T):T {
    var result:T = null;
    var done:Bool = false;

    haxe.Timer.delay(function() {
      result = handler();
      done = true;
    }, 0);

    while (true) {
#if nme
      var s:String = "alocate dummy string to prevent dead lock in hxcpp gc";
#end
      if (done) break;
    }
    return result;
  }
}

class PocoServer {

    var port:Int;
    var timer:Timer;
    var socket:Socket;
    var rpc:IRpc;

    public function new(rpc:IRpc, port:Int=15004) {
        this.rpc = rpc;
        this.port = port;

        Thread.create(createListeningSocket);
    }

    private function createListeningSocket():Void {
      socket = new sys.net.Socket();
			socket.bind(new sys.net.Host("0.0.0.0"), port);
      socket.listen(1);
      while (true) {
        var s:Socket = socket.accept();
        trace("new connection");
        var thrd = Thread.create(connection);
        thrd.sendMessage(s);
      }
      trace('listening on port $port');
    }

    private function connection():Void {
      var s:Socket = cast Thread.readMessage(true);
      var h = new Handler(s, rpc);
      while (true) {
        var needClose = h.update();
        if (needClose) break;
      }
      trace("closing connection");
    }
}

