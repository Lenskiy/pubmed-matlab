function metadata = parsePubMedXML(article)
    % Initialize the metadata structure
    metadata = struct();
    if(isempty(article))
        return;
    end
    % Extract the PMCID (PubMed Central ID)
    idNode = article.getElementsByTagName('PMID').item(0); % Assuming the first article-id is the PMCID
    if(~isempty(idNode))
        idStruct = xml2struct(idNode);
        metadata.PMID = idStruct.Data.double();
    end

    % Extract the article title
    metadata.Title = ""; % default value
    titleNode = article.getElementsByTagName('ArticleTitle').item(0); % Assuming the first article-title is the main title
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
                    metadata.Title = metadata.Title + "^" + titleStruct(k).Children(1).Data;
                case "xref"
                case "italic"
                    %metadata.Title = metadata.Title + "\textit{" + titleStruct(k).Children(1).Data + "}";
                    metadata.Title = metadata.Title + "(" + titleStruct(k).Children(1).Data + ")";
                case "sc"
                case "styled-content"
                case "fn"
                case "named-content"
                case "i"
                case "bold"
                    %metadata.Title = metadata.Title + "\textbf{" + titleStruct(k).Children(1).Data + "}";
                    metadata.Title = metadata.Title + "[" + titleStruct(k).Children(1).Data + "]";
                otherwise
                    warning("Unknown title tag: " + titleStruct(k).Name);
            end
        end
    end
    
    % Extract the authors' names
    namesNode = article.getElementsByTagName('AuthorList').item(0);
    authors = [];
    if ~isempty(namesNode)
        for k = 0:namesNode.getLength-1
            author.("firstname") = "";
            author.("lastname")  = "";
            nameStruct = xml2struct(namesNode.item(k));
            for l = 1:length(nameStruct)
                if(isfield(nameStruct(l), "Children"))
                    switch nameStruct(l).Name
                        case "LastName"
                            author.("lastname") = nameStruct(l).Children.Data;
                        case "ForeName"
                            author.("firstname") = nameStruct(l).Children.Data;
                        otherwise
                    end
                end
            end
            authors = [authors, author];
        end
    end
    metadata.Authors = {authors};

    % Extract the publication year
    % DateCompleted
    %pubDateNode = article.getElementsByTagName('DateCompleted').item(0); % Assuming the first year is the publication year
    pubDateNode = article.getElementsByTagName('ArticleDate').item(0);
    if(isempty(pubDateNode))
        pubDateNode = article.getElementsByTagName('DateCompleted').item(0);
    end
    if ~isempty(pubDateNode)
        dateStruct = xml2struct(pubDateNode);
        % Default date:
        day = 1; month = 1; year = 1900;
        for k = 1:length(dateStruct)
             switch dateStruct(k).Name
                 case "Day"
                     day = dateStruct(k).Children.Data.double;
                 case "Month"
                     month = dateStruct(k).Children.Data.double;
                 case "Year"
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
    end
    metadata.PubDate = datetime(year, month, day);
    
    % Extract the journal title
    journalTitleNode = article.getElementsByTagName('Journal').item(0); % Assuming the first journal-title is the main title
    if ~isempty(journalTitleNode)
        journalTitleStruct = xml2struct(journalTitleNode);
        metadata.Journal  = ""; % Default name 
        if isstruct(journalTitleStruct)
            for k = 1:length(journalTitleStruct)
                switch journalTitleStruct(k).Name
                    case "Title"
                        metadata.Journal = journalTitleStruct(3).Children.Data;
                    case "JournalIssue"
                    case "ISSN"
                    case "ISOAbbreviation"
                    otherwise
                        warning("Uknown title tag: " + journalTitleStruct(k).Name);
                end
            end
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
    abstractNode = article.getElementsByTagName('Abstract').item(0);
    if ~isempty(abstractNode)
        abstractsTemp = xml2struct(abstractNode);
        for l = 1:length(abstractsTemp)
            abstractTemp = abstractsTemp(l);
            if(isstruct(abstractsTemp))
                switch abstractsTemp(l).Name
                    case "AbstractText"
                        abstractTemp.Name = "p";
                        metadata.Abstract = metadata.Abstract + mergeParagraph(abstractTemp);
                    case "#text"
                        metadata.Abstract = metadata.Abstract + abstractsTemp.Data;
                    case "CopyrightInformation"
                    otherwise
                        warning("Unknown abstract tag: " + abstractsTemp(l).Name)
                end
            end
        end
    end
end
