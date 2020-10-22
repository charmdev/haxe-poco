package poco.sdk;

import poco.Protocol;

interface AbstractNode {
    function getChildren():Array<AbstractNode>;
    function enumerateAttrs():Payload;
}
