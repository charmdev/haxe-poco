package poco;

typedef Message = {
  id:String,
  jsonrpc:String
};

typedef RequestMessage = {
  > Message,
  method:String,
  params:Array<Any>
}

typedef ResponseMessage = {
  > Message,
  result:Null<Any>,
  error:Null<String>
}

typedef SerializedNode = {
    name:String,
    payload:Payload,
    ?children:Array<SerializedNode>
}

typedef Payload = {
    name:String,
    type:String,
    visible:Bool,
    pos:Array<Float>,
    size:Array<Float>,
    scale:Array<Float>,
    anchorPoint:Array<Float>,
    zOrders:{global:Int, local:Int}
}

typedef DumpResponse = SerializedNode;