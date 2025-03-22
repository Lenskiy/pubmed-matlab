function articles = retrievePubMedPapers(paperIDs, email, pmidsChunkLengths)
    db = "pubmed";
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

            articlesNodes = doc.getElementsByTagName("PubmedArticle");
            for l = 0:articlesNodes.getLength-1
                parsedPaper = parsePubMedXML(articlesNodes.item(l));
                articles(parsedPaper.PMID) = parsedPaper;
            end

            % for l = 1:length(articles.values)
            %     disp("[" + string(selectedPIMDS(l)) + "]" + ":" + articles(paperIDs(selectedPIMDS(l))).PMCID + ":"+ articles(paperIDs(selectedPIMDS(l))).Title);
            % end
            k = k + 1;
        end
    catch exception
        error('An error occurred: %s', exception.message);
    end

end