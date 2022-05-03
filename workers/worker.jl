#!/usr/bin/env julia
import Pkg

Pkg.activate(".")
Pkg.instantiate()

using JSON
using AMQPClient
using MOSCompute

import DotEnv
DotEnv.config()

Base.exit_on_sigint(false)

if haskey(ENV, "MOS_RABBIT_HOST")
    host = ENV["MOS_RABBIT_HOST"]
else
    host = "localhost"
end

if haskey(ENV, "MOS_RABBIT_PORT")
    port = parse(Int64, ENV["MOS_RABBIT_PORT"])
else
    port = 5672
end

if haskey(ENV, "MOS_RABBIT_USR")
    usr = ENV["MOS_RABBIT_USR"]
else
    usr = "guest"
end

if haskey(ENV, "MOS_RABBIT_PWD")
    pwd = ENV["MOS_RABBIT_PWD"]
else
    pwd = "guest"
end

if haskey(ENV, "MOS_COMPUTE_CONN_RETRIES_MAX")
    conn_retries_max = parse(Int64, ENV["MOS_COMPUTE_CONN_RETRIES_MAX"])
else
    conn_retries_max = 60
end

if haskey(ENV, "MOS_COMPUTE_CONN_RETRIES_INT")
    conn_retries_int = parse(Int64, ENV["MOS_COMPUTE_CONN_RETRIES_INT"])
else
    conn_retries_int = 5
end

auth_params = Dict{String,Any}(
    "MECHANISM"=>"AMQPLAIN", 
    "LOGIN"=>usr, 
    "PASSWORD"=>pwd
)

@info("MOS Julia worker")
@info("----------------")

amqps = amqps_configure()

conn_ok = false
conn_retries = 0
while conn_retries < conn_retries_max
    try
        global conn = connection(; 
            virtualhost="/", 
            host=host, 
            port=port, 
            auth_params=auth_params,
            amqps=nothing
        )
        global conn_ok = true
        break
    catch
        @info("Waiting for message queue to be available ...")
        sleep(conn_retries_int)
        global conn_retries += 1
    end
end
if !conn_ok
    throw("Unable to connect to rabbitmq")
end

chan = channel(conn, AMQPClient.UNUSED_CHANNEL, true)

queue_declare(chan, "mos-julia")

function callback(msg)
    body = JSON.parse(String(msg.data))
    @info("Task received $body")
    try
        MOSCompute.model_run(body["model_id"], 
                             body["model_name"],
                             body["caller_id"])
    catch e
        @error(e)
    end
    @info("Task done")
end

@info("Consuming messages ...")
success, consumer_tag = basic_consume(chan, "mos-julia", callback; no_ack=true)

while true
    try
        sleep(2)
    catch e   
        if e isa InterruptException
            @info("Exiting worker")  
            exit()
        else
            @error(e)
        end
    end
end 