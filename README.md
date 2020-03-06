# HubCLI.jl
A library that uses the [hub cli](https://github.com/github/hub) to interact with GitHub. As hub wraps the git cli you need git preinstalled but you may also use it to call into git.

# Exports

`Hub, Hub.hub, Hub.push_secret!`

HubCLI exports the module `Hub` which contains all functions. The decision was made to not to claim the Hub package name but to have everything behind the Hub module nevertheless. Also, qualifying the functions with the module name is considered good style for this package (as some visual marker since you're shelling out to interact with the 'hub').

```julia
Hub.hub(args...; [input])::(stdout::String, stderr::String, errorcode::Int)
```
shells out to `hub` passing arguments `args`. `input` will be passed as stdin.

```julia
Hub.push_secret!(gh_repo, pairs::Pair{String,Base.SecretBuffer}...)
```
Note: Shreds the passed `SecretBuffer`s after usage. `remote_gh_url` be something like "rapus95/HubCLI.jl". `pairs` is a list of `"key"=>value` pairs where the value needs to be a `Base.SecretBuffer`.
