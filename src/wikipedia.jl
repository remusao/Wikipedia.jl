
LANG = "en"
const API_URL_SUFFIX = "wikipedia.org/w/api.php"
const RATE_LIMIT = false
const RATE_LIMIT_MIN_WAIT = Nothing
const RATE_LIMIT_LAST_CALL = Nothing
const USER_AGENT = "wikipedia (https://github.com/remusao/Wikipedia.jl)"

# Change language
set_lang(prefix::String) = (global LANG; LANG = prefix)
# Change User agent
set_user_agent(user_agent::String) = (global USER_AGENT; USER_AGENT = user_agent)


function search(query::String; results=10, suggestion=false)
    search_params = {
        "list" => "search",
        "srprop" => "",
        "srlimit" => results,
        "limit" => results,
        "srsearch" => query
    }

    if suggestion
        search_params["srinfo"] = "suggestion"
    end

    raw_results = wiki_request(search_params)

    if "error" in raw_results
        if raw_results["error"]["info"] in ("HTTP request timed out.", "Pool queue is full")
            throw(HTTPTimeoutError(query))
        else
            throw(WikipediaException(raw_results["error"]["info"]))
        end
    end

    search_results = [d["title"] for d in raw_results["query"]["search"]]

    if suggestion
        if get(raw_results["query"], "searchinfo", false)
            return (search_results, raw_results["query"]["searchinfo"]["suggestion"])
        else
            return (search_results, Nothing)
        end
    end

    return search_results
end


function suggest(query::String)
    search_params = {
        "list" => "search",
        "srinfo" => "suggestion",
        "srprop" => "",
        "srsearch" => query
    }

    raw_result = wiki_request(search_params)

    if haskey(raw_result["query"], "searchinfo")
        return raw_result["query"]["searchinfo"]["suggestion"]
    end
end


function random(pages=1)
    #http://en.wikipedia.org/w/api.php?action=query&list=random&rnlimit=5000&format=jsonfm
    query_params = {
        "list" => "random",
        "rnnamespace" => 0,
        "rnlimit" => pages
    }

    request = wiki_request(query_params)
    titles = [page["title"] for page in request["query"]["random"]]

    if length(titles) == 1
        return titles[1]
    end

    return titles
end


function summary(title; sentences=0, chars=0, auto_suggest=true, redirect=true)
    # use auto_suggest and redirect to get the correct article
    # also, use page's error checking to raise DisambiguationError if necessary
    page_info = page(title, auto_suggest=auto_suggest, redirect=redirect)
    title = page_info.title
    pageid = page_info.pageid

    query_params = {
        "prop" => "extracts",
        "explaintext" => "",
        "titles" => title
    }

    if sentences != 0
        query_params["exsentences"] = sentences
    elseif chars != 0
        query_params["exchars"] = chars
    else
        query_params["exintro"] = ""
    end

    request = wiki_request(query_params)
    return request["query"]["pages"][string(pageid)]["extract"]
end


function page(title::String; auto_suggest=true, redirect=true, preload=false)
    if auto_suggest
        results, suggestion = search(title, results=1, suggestion=true)
        try
            title = suggestion != Nothing ? suggestion : results[1]
        catch
            # if there is no suggestion or search results, the page doesn't exist
            throw(PageError(title))
        end
    end
    return WikipediaPage(title, redirect, preload)
end


function page(pageid::Integer, preload=false)
    return WikipediaPage(pageid; preload=preload)
end


function languages()
    response = wiki_request({
        "meta" => "siteinfo",
        "siprop" => "languages"
    })
    langs = response["query"]["languages"]
    return {lang["code"] => lang["*"] for lang in langs}
end
