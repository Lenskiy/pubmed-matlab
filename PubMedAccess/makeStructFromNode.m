function nodeStruct = makeStructFromNode(theNode)
% Create structure of node info.
nodeStruct = struct(...
   'Name',          string(theNode.getNodeName),...
   'Attributes',    parseAttributes(theNode),  ...
   'Data', "",...
   'Children',      xml2struct(theNode));

if any(strcmp(methods(theNode), 'getData'))
   nodeStruct.Data = string(theNode.getData).replace(newline, " "); 
else
   nodeStruct.Data = "";
end