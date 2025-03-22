function pidsPMCTable = requestIDs(query, email, startYear, endYear, database)
    arguments
        query = ""
        email = "something@mail.au"
        startYear = 2025 
        endYear   = 2025
        database  = "pmc"
    end
    % Request PMC paper IDs
    barHandle = waitbar(0);
    pidsPMCTable = table([], [], VariableNames = ["year", "pid"]);
    for curYear = startYear:endYear
        msg = "Year:"  + curYear;
        waitbar((curYear - startYear) / (endYear - startYear), barHandle, msg);
        startDate = string(curYear) + "/" + "01" + "/" + "01";
        endDate   = string(curYear) + "/" + "12" + "/" + "31";
        pids = searchByKeywords(query, startDate, endDate, database, email);
        pidsPMCTable = [pidsPMCTable; array2table([curYear * ones(length(pids), 1), pids], VariableNames = ["year", "pid"])];
    end
    close(barHandle);
end

