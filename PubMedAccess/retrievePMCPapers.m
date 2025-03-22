function articles = retrievePMCPapers(paperIDs, email, pmidsChunkLengths)
    db = "pmc";
    articles = dictionary();
    startIndex = 1;
    try
        k = startIndex;
        while k <= ceil(numel(paperIDs)/pmidsChunkLengths)
            base_url = "https://eutils.ncbi.nlm.nih.gov";
            request = matlab.net.URI(base_url);
            request.Path = "/entrez/eutils/efetch.fcgi";
            request.Query(1) = matlab.net.QueryParameter("db",      db);                                                    
            selectedPIMDS = (k - 1) * pmidsChunkLengths + 1 : min(k*pmidsChunkLengths, length(paperIDs));
            request.Query(2) = matlab.net.QueryParameter("id", join(string(paperIDs(selectedPIMDS)), ","));
            request.Query(3) = matlab.net.QueryParameter("rettype", "abstract");
            request.Query(4) = matlab.net.QueryParameter("retmode", "xml");
            request.Query(5) = matlab.net.QueryParameter("usehistory", "y");
            request.Query(6) = matlab.net.QueryParameter("email", email);
            
            try
                pause(1);
                doc = webread(request, weboptions(Timeout=10,  ContentType="xml"));
            catch exception
                disp(exception.message);
                continue;
            end
         
            articleset = doc.item(1).getChildNodes();
            
            for l = 0:articleset.getLength
                node = articleset.item(l);
                if isempty(node) 
                    continue
                end
                if node.getNodeType ~= 1
                    continue
                end
                
                articleFront = node.getElementsByTagName('front').item(0);
                if(~isempty(articleFront))
                    parsedPaper = parsePMCXML(articleFront);
                    articles(parsedPaper.PMCID) = parsedPaper;
                end
            end

            keys = articles.keys;
            for l = 1:articles.numEntries
                disp("[" + string(keys(l)) + "]" + ":" + articles(keys(l)).PMCID + ":"+ articles(keys(l)).Title);
            end
            k = k + 1;
        end
    catch exception
        error('An error occurred: %s', exception.message);
    end

end