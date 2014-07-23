
type WikipediaException <: Exception
end


type PageError <: Exception
    pageid
    title
end

PageError(pageid::Integer) = PageError(pageid, Nothing)
PageError(title::String) = PageError(Nothing, title)


type DisambiguationError <: Exception
    title
    may_refer_to
end


type RedirectError <: Exception
    title
end


type HTTPTimeoutError <: Exception
    query
end
