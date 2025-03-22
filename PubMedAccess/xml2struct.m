function children = xml2struct(theNode)
% Recurse over node children.
children = [];
if(~any(methods(theNode) == "hasChildNodes"))
    return;
end

if theNode.hasChildNodes
   childNodes = theNode.getChildNodes;
   numChildNodes = childNodes.getLength;
   %allocCell = cell(1, numChildNodes);
    
   for count = 1:numChildNodes
       theChild         = childNodes.item(count-1);
       structuredChild  = makeStructFromNode(theChild);
       if(~isempty(structuredChild.Children) || structuredChild.Data.strip().strlength ~= 0)
           children = [children, structuredChild]; 
       end
   end
end
