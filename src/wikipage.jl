
type WikipediaPage
    title::String
    original_title::String
    pageid::Int
    url::String
end


function WikipediaPage(title::String, redirect=true, preload=false, original_title="")
    wikipage = WikipediaPage(title, original_title, -1, "")
    return _load_page(wikipage; redirect=redirect, preload=preload)
end


function WikipediaPage(pageid::Integer; redirect=true, preload=false, original_title="")
    wikipage = WikipediaPage("", original_title, pageid, "")
    return _load_page(wikipage; redirect=redirect, preload=preload)
end


#
# Utility functions
#

function content(wikipage::WikipediaPage)

end


function revision_id(wikipage::WikipediaPage)

end


function parent_id(wikipage::WikipediaPage)

end


function summary(wikipage::WikipediaPage)

end


function images(wikipage::WikipediaPage)

end


function coordinates(wikipage::WikipediaPage)

end


function references(wikipage::WikipediaPage)

end


function links(wikipage::WikipediaPage)

end


function sections(wikipage::WikipediaPage)

end


function section(wikipage::WikipediaPage, section_title::String)

end


#
# Internals
#

# Load basic information from Wikipedia.
# Confirm that page exists and is not a disambiguation/redirect.
#
# Does not need to be called manually, should be called automatically during __init__.
function _load_page(wikipage::WikipediaPage; redirect=true, preload=false)
    query_params = {
      "prop" => "info|pageprops",
      "inprop" => "url",
      "ppprop" => "disambiguation",
      "redirects" => ""
    }

    if wikipage.pageid == -1
        query_params["titles"] = wikipage.title
    else
        query_params["pageids"] = wikipage.pageid
    end

    request = wiki_request(query_params)

    query = request["query"]
    pageid = collect(keys(query["pages"]))[1]
    page = query["pages"][pageid]

    # missing is present if the page is missing
    if "missing" in page
        if wikipage.title != ""
            throw(PageError(wikipage.title))
        else
            throw(PageError(wikipage.pageid))
        end
    # Same thing for redirect, except it shows up in query instead of page for
    # whatever silly reason
    elseif "redirects" in query
        if redirect
            redirects = query["redirects"][1]

            if "normalized" in query
                normalized = query["normalized"][1]
                @assert normalized["from"] == page.title

                from_title = normalized["to"]
            else
                from_title = wikipage.title
            end

            @assert redirects["from"] == from_title

            # change the title and reload the whole object
            wikipage = WikipediaPage(redirects["to"], redirect=redirect, preload=preload)
        else
            throw(RedirectError(wikipage.title != "" ? wikipage.title : page["title"]))
        end

    # since we only asked for disambiguation in ppprop,
    # if a pageprop is returned,
    # then the page must be a disambiguation page
    elseif "pageprops" in page
        query_params = {
            "prop" => "revisions",
            "rvprop" => "content",
            "rvparse" => "",
            "rvlimit" => 1
        }
        if wikipage.pageid != -1
            query_params["pageids"] = wikipage.pageid
        else
            query_params["titles"] = wikipage.title
        end

        request = wiki_request(query_params)
        # html = request["query"]["pages"][pageid]["revisions"][1]["*"]

        # lis = BeautifulSoup(html).find_all('li')
        # filtered_lis = [li for li in lis if not 'tocsection' in ''.join(li.get('class', []))]
        # may_refer_to = [li.a.get_text() for li in filtered_lis if li.a]

        thow(DisambiguationError(wikipage.title != "" ? wikipage.title : page["title"], ""))
    else
        wikipage.pageid = int(pageid)
        wikipage.title = page["title"]
        wikipage.url = page["fullurl"]
    end

    return wikipage
end


#  Based on https://www.mediawiki.org/wiki/API:Query#Continuing_queries
function _continued_query(wikipage::WikipediaPage, query_params)

    merge!(query_params, wikipage.title != "" ?
        {"titles" => wikipage.title}
        : {"pageids" => wikipage.pageid})

    last_continue = Dict()
    prop = get(query_params, "prop", Nothing)

    results = Vector()
    while true
        params = copy(query_params)
        merge!(params, last_continue)

        request = wiki_request(params)

        if !("query" in request)
            break
        end

        pages = request["query"]["pages"]
        if "generator" in query_params
            append!(results, values(pages))
        else
            append!(results, pages[wikipage.pageid][prop])
        end

        if !("continue" in request)
            break
        end

        last_continue = request["continue"]
    end

    return results
end
