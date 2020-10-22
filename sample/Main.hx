package;

import poco.PocoServer.IRpc;


class Rpc implements IRpc {
    public function new() {}

    public function dump():poco.Protocol.DumpResponse {
        return {
            name:"<Root>",
            payload:{
                name:"<Root>",
                type:"node",
                visible:true,
                pos:[0.0, 0.0],
                size:[1.0, 1.0],
                scale:[1.0, 1.0],
                anchorPoint:[0.5, 0.5],
                zOrders:{global:0, local:0}
            },
            children:[]
        }
    }
}

class Main {
    public static function main() {
        var poco = new poco.PocoServer(new Rpc(), 15004);
    }
}