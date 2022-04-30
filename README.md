# mos-compute-jl

MOS Julia compute worker.

## Pre-requisites

### Services

* rabbitmq
* mos-backend

### Dependencies

```
import Pkg
Pkg.activate(".")
Pkg.instantiate()
```

### Environment variables

The following environment variables can be specified. They can be provided via a .env file.

* MOS_BACKEND_HOST:
* MOS_BACKEND_PORT:
* MOS_ADMIN_USR:
* MOS_ADMIN_PWD:
* MOS_RABBIT_PORT:
* MOS_RABBIT_USR:
* MOS_RABBIT_PWD:
* MOS_RABBIT_HOST:

## Local Deployment

Launch a Julia worker by executing ``./workers/worker.jl``.

## Docker Deployment

The following scripts are available for building the image, running the container, and for pushing the image to Docker Hub:

* ``./scripts/docker_build.sh``
* ``./scripts/docker_run.sh``
* ``./scripts/docker_push.sh``
