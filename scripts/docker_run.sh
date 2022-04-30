#!/bin/bash
sudo docker run -it \
                --rm \
                --network=host \
                --env-file=.env \
                --name=mos-compute-jl \
                tomastinoco/mos-compute-jl