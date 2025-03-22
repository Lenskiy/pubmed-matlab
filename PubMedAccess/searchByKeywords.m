function pmids = searchByKeywords(query, startDate, endDate, db, email)
    import matlab.io.xml.dom.*;

    searchQuery = "(" + query + ") AND (" + startDate + "[PDAT] : " + endDate + "[PDAT])";

    request = matlab.net.URI("https://eutils.ncbi.nlm.nih.gov");
    request.Path = "/entrez/eutils/esearch.fcgi";
    request.Query(1) = matlab.net.QueryParameter("db",      db);
    request.Query(2) = matlab.net.QueryParameter("term",    searchQuery);
    request.Query(3) = matlab.net.QueryParameter("retmax",  1000000);
    request.Query(4) = matlab.net.QueryParameter("retmode", "xml");
    request.Query(5) = matlab.net.QueryParameter("usehistory", "y");
    request.Query(6) = matlab.net.QueryParameter("email", email);

    while(1)
        try
            xmlData = webread(request, weboptions("Timeout", 5, "ContentType", "xmldom"));
            pmids = parsePubMedSearchXML(xmlData);
            break;
        catch exception
            warning(['An error occurred: %s', exception.message]);
        end
    end
end

function ids = parsePubMedSearchXML(xmlDoc)
    idElements = xmlDoc.getElementsByTagName('Id');
    ids = zeros(idElements.getLength, 1);

    for i = 0:idElements.getLength - 1
        idElement = idElements.item(i);
        ids(i + 1) = str2double(char(idElement.getTextContent));
    end
end
