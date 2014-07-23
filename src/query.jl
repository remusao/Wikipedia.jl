
function wiki_request(params::Dict)
    params["format"] = "json"
    if !in("action", params)
        params["action"] = "query"
    end

    headers = {
        "User-Agent" => USER_AGENT
    }

    r = get("http://$(LANG).$(API_URL_SUFFIX)"; query = params, headers = headers)
    return JSON.parse(r.data)
end
