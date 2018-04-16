version: '2'

services:
  sonarqube-storage:
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: true
    image: rawmind/alpine-volume:0.0.2-1

  sonarqube:
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.sidekicks: sonarqube-storage
    image: sonarqube:${docker_version}
