version: '2'

services:
  sonarqube-storage:
    image: rawmind/alpine-volume:0.0.2-1

  sonarqube:
    image: sonarqube:${docker_version}
