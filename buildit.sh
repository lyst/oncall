#!/usr/bin/env bash

set -euo pipefail

REPO=924697190257.dkr.ecr.eu-west-1.amazonaws.com/grafana_oncall
export AWS_PROFILE=ecs
VERSION=$(git describe --always --dirty --broken --tags)
REPOTAG=$REPO:$VERSION

echo "Building new image..."

make build

read -p "Image built - proceed to push to $REPOTAG? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "OK - pushing updated image..."
  docker tag oncall-oncall_engine:latest "$REPOTAG"
  docker tag oncall-oncall_engine:latest $REPO
  docker push $REPO
  docker push "$REPOTAG"

  echo -e "Pushed $REPOTAG\nSSH into OnCall server & redeploy the image with:"
  echo -e "\n  docker-compose pull\n  docker-compose up -d"
else
  echo "Aborting without image push"
fi
