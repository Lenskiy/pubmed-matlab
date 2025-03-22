function metadata = parsePMCXML(article)
    % Initialize the metadata structure
    metadata = struct();

    % Extract the PMCID (PubMed Central ID)
    metadata.PMCID = 0;
    metadata.DOI = "";
    metadata.PMID = 0;
    idNode = article.getElementsByTagName('article-meta').item(0); % Assuming the first article-id is the PMCID
    idStruct = xml2struct(idNode);
    for k = 1:length(idStruct)
        if(idStruct(k).Name == "article-id")
            switch idStruct(k).Attributes.Value
                case "pmc"
                    metadata.PMCID  = idStruct(k).Children(1).Data.double;
                case "doi"
                    metadata.DOI   = idStruct(k).Children(1).Data;
                case "pmid"
                    metadata.PMID  = idStruct(k).Children(1).Data.double;
                case "publisher-id"
                case "pii"
                case "other"
                case "publisher-manuscript"
                case "art-access-id"
                case "manuscript"
                case "medline"
                case "coden"
                case "sici"
                otherwise
                    warning("Uknown paper identfier: " + idStruct(k).Attributes.Value)
            end
        end
    end


    % Extract the article title
    metadata.Title = ""; % default value
    titleNode = article.getElementsByTagName('article-title').item(0); % Assuming the first article-title is the main title
    if ~isempty(titleNode)
        %metadata.Title  = string(titleNode.getTextContent());
        titleStruct = xml2struct(titleNode);
        for k = 1:length(titleStruct)
            switch titleStruct(k).Name
                case "#text"
                    metadata.Title = metadata.Title + titleStruct(k).Data;
                %case "p"
                %    metadata.Title = metadata.Title + mergeParagraph(titleStruct(k));
                case "sub"
                    %metadata.Title = metadata.Title + "\textsubscript{" + titleStruct(k).Children(1).Data + "}";
                    metadata.Title = metadata.Title + "_" + titleStruct(k).Children(1).Data;
                case "sup"
                    %metadata.Title = metadata.Title + "\textsuperscript{" + titleStruct(k).Children(1).Data + "}";
                    metadata.Title = metadata.Title + "^" + titleStruct(k).Children(1).Data
                case "xref"
                case "italic"
                    %metadata.Title = metadata.Title + "\textit{" + titleStruct(k).Children(1).Data + "}";
                    metadata.Title = metadata.Title + "(" + titleStruct(k).Children(1).Data + ")";
                case "sc"
                case "styled-content"
                case "fn"
                case "named-content"
                case "bold"
                    %metadata.Title = metadata.Title + "\textbf{" + titleStruct(k).Children(1).Data + "}";
                    metadata.Title = metadata.Title + "[" + titleStruct(k).Children(1).Data + "]";
                otherwise
                    warning("Unknown title tag: " + titleStruct(k).Name);
            end
        end
    end
    
    % Extract the authors' names
    namesNode = article.getElementsByTagName('name');
    authors = [];
    for k = 0:namesNode.getLength-1
        author.("firstname") = "";
        author.("lastname")  = "";
        nameStruct = xml2struct(namesNode.item(k));
        for l = 1:length(nameStruct)
            if(isfield(nameStruct(l), "Children"))
                switch nameStruct(l).Name
                    case "surname"
                        author.("lastname") = nameStruct(l).Children.Data;
                    case "given-names"
                        author.("firstname") = nameStruct(l).Children.Data;
                    otherwise
                end
            end
        end
        authors = [authors, author];
    end
    metadata.Authors = {authors};

    % Extract the publication year
    pubDate = article.getElementsByTagName('pub-date').item(0); % Assuming the first year is the publication year
    dateStruct = xml2struct(pubDate);
    % Default date:
    day = 1; month = 1; year = 1900;
    for k = 1:length(dateStruct)
         switch dateStruct(k).Name
             case "day"
                 day = dateStruct(k).Children.Data.double;
             case "month"
                 month = dateStruct(k).Children.Data.double;
             case "year"
                 year = dateStruct(k).Children.Data.double;
             case "string-date"
                 months = ["Jan", "Feb", "Mar", "Apr",...
                           "May", "Jun", "Jul", "Aug",...
                           "Sep", "Oct", "Nov", "Dec"];

                 dateTokens = dateStruct(k).Children.Data.split;
 
                 for l = 1:length(dateTokens)
                    num = dateTokens(l).strip(",").double;
                    if(~isnan(num))
                        if(num <= 31)
                            day = num;
                        elseif (1900 <= num)
                            year = num;
                        end
                    else
                        for m = 1:12
                            if(dateTokens(l).contains(months(m)))
                                month = m;
                                break;
                            end
                        end               
                    end
                 end
                 
                 tempDate = datetime(year, month, day); % the string date format might change
                 year = tempDate.Year;
                 month = tempDate.Month;
                 day = tempDate.Day;
             case "season"
             case "#comment"
             otherwise
                 warning("Unknown date field: " + dateStruct(k).Name)
         end
    end
    metadata.PubDate = datetime(year, month, day);
    
    % Extract the journal title
    journalTitleNode = article.getElementsByTagName('journal-title').item(0); % Assuming the first journal-title is the main title
    journalTitleStruct = xml2struct(journalTitleNode);
    metadata.Journal  = ""; % Default name 
    if isstruct(journalTitleStruct)
        if(isstring(journalTitleStruct.Data))
            metadata.Journal = journalTitleStruct.Data;
        end
    end
    
    % % Extract volume and issue
    % volumeNode = article.getElementsByTagName('volume').item(0); % Assuming the first volume is the main volume
    % if ~isempty(volumeNode)
    %     volume = char(volumeNode.getTextContent());
    %     metadata.Volume = volume;
    % end
    % 
    % issueNode = article.getElementsByTagName('issue').item(0); % Assuming the first issue is the main issue
    % if ~isempty(issueNode)
    %     issue = char(issueNode.getTextContent());
    %     metadata.Issue = issue;
    % end
    
    metadata.Abstract = ""; % Default value;
    abstractNode = article.getElementsByTagName('abstract');
    if ~isempty(abstractNode)
        for k = 0:abstractNode.getLength-1
            abstractTemp = xml2struct(abstractNode.item(k));
            for l = 1:length(abstractTemp)
                if(isstruct(abstractTemp))
                    switch abstractTemp(l).Name
                        case "title"
                        case "p"
                            metadata.Abstract = metadata.Abstract + mergeParagraph(abstractTemp(l));
                        case "sec"
                            for m = 1:length(abstractTemp(l).Children)
                                switch abstractTemp(l).Children(m).Name
                                    case "title"
                                    case "p"
                                        metadata.Abstract = metadata.Abstract + mergeParagraph(abstractTemp(l).Children(m));
                                    otherwise
                                        warning("Unknown abstract/sec tag: " + abstractTemp(l).Children(m).Name);
                                end
                            end
                        case "disp-quote"
                        otherwise
                            warning("Unknown abstract tag: " + abstractTemp(l).Name)
                    end
                end
            end
        end
    end
end
