#!/bin/bash
sudo docker run -it \
                --rm \
                --network=host \
                --env-file=.env \
                --name=mos-demo-compute-jl \
                tomastinoco/mos-demo-compute-jl