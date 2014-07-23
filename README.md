# Wikipedia.jl

This package provides basic utilities to access the *Wikipedia* API.
It is freely inspired from [wikipedia](https://github.com/goldsmith/Wikipedia), but some improvments are planned.


## Quickstart

```julia
julia> Pkg.clone("https://github.com/Keno/Requests.jl.git")
julia> Pkg.update()
julia> using Wikipedia
```

## Features

```julia
julia> Wikipedia.summary("Batman")
"Batman is a fictional superhero who appears in American comic books published by DC Comics, as well as in a multitude of movies, television shows, and video games. He was created by Bob Kane and Bill Finger in 1939 to capitalize on the superhero craze that began with Superman. Batman is one of DC Comics' most recognizable and profitable characters.\nBatman is a vigilante who wears a bat-like costume and fights violent criminals in the fictional city of Gotham. He is a brilliant detective and formidable martial artist. Batman's real name is Bruce Wayne, a billionaire industrialist. When he was a child, his parents were murdered by a common mugger, and he fights criminals to avenge their deaths.\n\n"
julia> Wikipedia.search("Batman")
10-element Array{Any,1}:
    "Batman"
    "B.A.T.M.A.N."
    "Batman (disambiguation)"
    "BATMAN"
    "Batman (comic book)"
    "Batman (TV series)"
    "Batman (1989 film)"
    "Batman: The Animated Series"
    "Batman in film"
    "List of Batman comics"
```
