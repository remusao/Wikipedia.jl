
module Wikipedia

    using Requests
    using JSON

    export languages
    export search
    export suggest
    export page
    export random
    export wiki_request

    include("wikipedia.jl")
    include("wikipage.jl")
    include("query.jl")
    include("exceptions.jl")
end
