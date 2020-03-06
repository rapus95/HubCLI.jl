module Hub
    using hub_jll, Sodium, JSON3
    export push_secret!

    function hub(args...; input=nothing)
        hub_jll.hub() do hub
            out = Pipe()
            err = Pipe()

            if input === nothing
                process = run(pipeline(ignorestatus(`$hub $args`), stdout=out, stderr=err))
            else
                process = run(pipeline(ignorestatus(`$hub $args`), stdin=input, stdout=out, stderr=err))
            end
            close(out.in)
            close(err.in)

            String(read(out)), String(read(err)), process.exitcode
        end
    end

    """
        function gh_push_secret!(remote_gh_url, pairs::Pair{String,Base.SecretBuffer}...)

    Important: Shreds the passed `SecretBuffer`s after usage.

    `remote_gh_url` be something like "JuliaWeb/Github.jl". `pairs` is a list of `"key"=>value` pairs where
    the value needs to be a `Base.SecretBuffer`.
    """
    function push_secret!(remote_gh_url, pairs::Pair{String,Base.SecretBuffer}...)
        result, _, _ = hub(:api, "/repos/$remote_gh_url/actions/secrets/public-key")
        answer = JSON3.read(result)
        get(answer, :message, nothing) == "Not Found" && error("Something went wrong at retrieving the public api key")

        requestjson = IOBuffer()
        requestbody = Dict{Symbol,Any}(:key_id=>answer[:key_id])
        for (secretname, secretvalue) in pairs
            requestbody[:encrypted_value] = seal(secretvalue, answer[:key])
            JSON3.write(requestjson, requestbody)
            seekstart(requestjson)
            ack = hub(:api, "-X", :PUT, "/repos/$remote_gh_url/actions/secrets/$secretname", "--input", "-", input=requestjson)
            truncate(requestjson, 0)
            isempty(ack[1]) || error(ack[2])
        end
    end
end