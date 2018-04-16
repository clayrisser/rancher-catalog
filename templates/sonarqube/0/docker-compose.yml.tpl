version: '2'

services:
  sonarqube-storage:
    image: rawmind/alpine-volume:0.0.2-1
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.container.start_once: true
    environment:
      SERVICE_UID: 0
      SERVICE_GID: 0
      SERVICE_VOLUME: /opt/sonarqube/extensions/plugins
    volume_driver: ${volume_driver}
    volumes:
      - {{.Stack.Name}}--sonarqube-plugins:/opt/sonarqube/extensions/plugins

  sonarqube:
    image: sonarqube:${docker_version}
    labels:
      io.rancher.container.hostname_override: container_name
      io.rancher.sidekicks: sonarqube-storage
{{- if eq .Values.enable_ports "true"}}
    ports:
      - 9000:9000
{{- end}}
    environment:
      SONARQUBE_WEB_JVM_OPTS: ${jvm_opts}
      SONARQUBE_JDBC_USERNAME: ${postgres_user}
      SONARQUBE_JDBC_PASSWORD: ${postgres_password}
      SONARQUBE_JDBC_URL: jdbc:postgresql://db:${postgres_port}/${postgres_db}
    volumes_from:
      - sonarqube-storage
