function articlesPMC = requestArticles(pidsTable, email, database)
    arguments
        pidsTable
        email = "something@mail.au"
        database  = "pmc"
    end

    % Request articles with these IDs
    barHandle = waitbar(0);
    chunkLength = 50;   % For larger chunks sometime produces errors
    articlesPMC = table();
    numberOfChunks = ceil(height(pidsTable)/chunkLength);
    for k =  1:numberOfChunks
        msg = "Papers retrieved: "  + k * chunkLength;
        waitbar((k-1) / numberOfChunks, barHandle, msg);
        indx = (k-1)*chunkLength+1:min(k*chunkLength, height(pidsTable));
        switch(database)
            case "pmc"
                articlesChunk = retrievePMCPapers(pidsTable(indx,2).Variables, email, min(chunkLength, length(indx)));
            case "pubmed"
                articlesChunk = retrievePubMedPapers(pidsTable(indx,2).Variables, email, min(chunkLength, length(indx)));
            otherwise
                error("Unkown database")
        end
        articlesPMC = [articlesPMC; struct2table(articlesChunk.values)];
        %struct2table(articlesChunk.values)
    end
    close(barHandle);
end