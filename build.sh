#!/bin/bash
docker system prune -f && docker image build --no-cache -t otherman16/contrainer:1.0 -f Dockerfile .
