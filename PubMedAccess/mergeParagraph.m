function merged = mergeParagraph(paragraphStruct)
    merged = "";
    if(isfield(paragraphStruct, "Name"))
        if(paragraphStruct.Name ~= "p")
            disp("Not a pargraph");
            return;         
        end
    else
        disp("Not a pargraph");
        return; 
    end
    
    if(~isfield(paragraphStruct, "Children"))
        disp("The paragraph is empty");
        return; 
    else
        children = paragraphStruct.Children;
    end

    for k = 1:length(children)
        if(~isfield(children(k), "Name"))
            continue;
        end

        % if(isfield(children(k), "Children"))
        %     if(~isempty(children(k).Children))
        %         %recurse inside.
        %     end
        % end

        switch(children(k).Name)
            case "#text"
                if(isfield(children(k), "Data"))
                    if(isstring(children(k).Data))
                        merged = merged + children(k).Data;
                    end
                end
            case "italic"
                if(isfield(children(k), "Children"))
                    if(~isempty(children(k).Children))
                        if(isfield(children(k).Children(1), "Data"))
                            if(isstring(children(k).Children(1).Data))
                                merged = merged + ""  + children(k).Children(1).Data + "";
                                %merged = merged + "\textit{"  + children(k).Children(1).Data + "}"; % for now, no recursion and assumes only one child.
                            end
                        end
                    end
                end
            case "bold"
                if(isfield(children(k), "Children"))
                    if(~isempty(children(k).Children))
                        if(isfield(children(k).Children(1), "Data"))
                            if(isstring(children(k).Children(1).Data))
                                %merged = merged + "\textbf{"  + children(k).Children(1).Data + "}"; % for now, no recursion and assumes only one child.
                                merged = merged + ""  + children(k).Children(1).Data + "";
                            end
                        end
                    end
                end
            case "sub"
                if(isfield(children(k), "Children"))
                    if(~isempty(children(k).Children))
                        if(isfield(children(k).Children(1), "Data"))
                            if(isstring(children(k).Children(1).Data))
                                %merged = merged + "\textsubscript{"  + children(k).Children(1).Data + "}"; % for now, no recursion and assumes only one child.
                                merged = merged + "_"  + children(k).Children(1).Data + "";
                            end
                        end
                    end
                end
            case "sup"
                if(isfield(children(k), "Children"))
                    if(~isempty(children(k).Children))
                        if(isfield(children(k).Children(1), "Data"))
                            if(isstring(children(k).Children(1).Data))
                                if(~isempty(children(k).Children(1).Children))
                                    continue; % if exists, the probaby a reference, or similar then skip.
                                end
                                %merged = merged + "\textsuperscript{"  + children(k).Children(1).Data + "}"; % for now, no recursion and assumes only one child.
                                 merged = merged + "^"  + children(k).Children(1).Data + "";
                            end
                        end
                    end
                end
            case "fig"
                % for now skip
            case "inline-formula"
                % for now skip
            case "list"
                % for now skip
            case "ext-link"
                % for now skip
            case "sc"
                % for now skip
            case "xref"
                % for now skip
            case "styled-content"
                % for now skip
            case "underline"
                % for now skip
            case "media"
            case "monospace"
            case "mml:math"
            case "named-content"
            case "mixed-citation"
            case "table-wrap"
            case "email"
            case "uri"
            case "related-article"
            case "i"
            otherwise
                warning("Unknown tag: " + children(k).Name);
        end
    end
end