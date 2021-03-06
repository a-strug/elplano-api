#!/usr/bin/env sh
set -e
set -v

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

docker pull ${DOCKER_REPOSITORY}:latest || true
docker pull ${DOCKER_REPOSITORY}:${TRAVIS_COMMIT} || true

docker build -t ${DOCKER_REPOSITORY}:${TRAVIS_COMMIT} --pull=true .

docker push ${DOCKER_REPOSITORY}:${TRAVIS_COMMIT}

docker tag ${DOCKER_REPOSITORY}:${TRAVIS_COMMIT} ${DOCKER_REPOSITORY}:latest

docker push ${DOCKER_REPOSITORY}:latest

