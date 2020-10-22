![CI](https://github.com/charmdev/haxe-poco/workflows/CI/badge.svg)
# haxe-poco
helps integrate Airtest poco sdk into haxe cpp project.
# What is Poco and AirTest?
Great framework for Automate UI testing.
Read more:
https://airtest.doc.io.netease.com/en/IDEdocs/poco_framework/poco_quick_start/
https://poco.readthedocs.io/en/latest/source/doc/integration.html
# How to use it in haxe project:
1. implement IRpc for e.g. like this:
```
import poco.Protocol;

class YourRpc implements poco.PocoServer.IRpc
{
    var dumper:YourDumper;

    public function new() 
    {
        dumper = new YourDumper();
    }

    public function dump():DumpResponse
    {
        return dumper.dumpHierarchy();
    }
}

class YourDumper implements poco.sdk.AbstractDumper
{
    var root:GameRoot;

    public function new()
    {
        root = new GameRoot();
    }

    public function dumpHierarchy():SerializedNode
    {
        return dumpHierarchyImpl(root);
    }

    private function dumpHierarchyImpl(node:poco.sdk.AbstractNode, onlyVisibleNode:Bool=true):SerializedNode
    {
        var payload:Payload = node.enumerateAttrs();
        var nodeChildren = node.getChildren();

        var result:SerializedNode = 
        {
            name:payload.name,
            payload:payload
        };

        var children = [];
        for (child in nodeChildren)
        {
            var childNode:SerializedNode = dumpHierarchyImpl(child, onlyVisibleNode);
            if (!onlyVisibleNode || childNode.payload.visible)
                children.push(childNode);
        }

        if (children.length > 0) 
            result.children = children;

        return result;
    }
}
```

2. initialize PocoServer with your rpc and start it:
```
var poco = new PocoServer(rpc, port:Int=15004);
```
3. Start your project and connect it with AirtestIDE
