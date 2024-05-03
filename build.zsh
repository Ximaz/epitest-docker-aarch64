#!/bin/zsh

TAG="latest"

build() {
    docker build --no-cache --tag "${DOCKERHUB_REPOSITORY}:${TAG}" .
}

deploy() {
    echo "${DOCKERHUB_TOKEN}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
    docker push "${DOCKERHUB_REPOSITORY}"
    git push origin main
}

main() {
    build
    deploy
}

main
