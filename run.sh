#!/bin/bash
make dev
docker build -t gotmpl:latest .
docker run -it --rm gotmpl:latest
