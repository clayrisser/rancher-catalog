version: '2'

services:
  agent:
    image: drone/agent:${version}
    environment:
      DRONE_SERVER: drone:9000
      DRONE_SECRET: ${secret}
      DOCKER_API_VERSION: 1.24
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    links:
      - drone:drone
    command:
      - agent
    labels:
      io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
      io.rancher.container.hostname_override: container_name

  drone:
    image: drone/drone:${version}
{{- if (.Values.public_port)}}
    ports:
      - ${public_port}:8000
{{- end}}
    environment:
      DRONE_HOST: ${base_url}
      GIN_MODE: release
      DRONE_SECRET: ${secret}
      DRONE_OPEN: ${open_registration}
{{- if (.Values.drone_admin)}}
      DRONE_ADMIN: ${drone_admin}
{{- end}}
{{- if (.Values.organizations)}}
      DRONE_ORGS: ${organizations}
{{- end}}
{{- if eq .Values.remote_driver "GitHub"}}
      DRONE_GITHUB: true
      DRONE_GITHUB_CLIENT: ${remote_driver_client}
      DRONE_GITHUB_SECRET: ${remote_driver_secret}
{{- end}}
{{- if eq .Values.remote_driver "Bitbucket Cloud"}}
      DRONE_BITBUCKET: true
      DRONE_BITBUCKET_CLIENT: ${remote_driver_client}
      DRONE_BITBUCKET_SECRET: ${remote_driver_secret}
{{- end}}
{{- if eq .Values.remote_driver "Bitbucket Server"}}
      DRONE_STASH: true
      DRONE_STASH_GIT_USERNAME: ${remote_driver_user}
      DRONE_STASH_GIT_PASSWORD: ${remote_driver_password}
      DRONE_STASH_CONSUMER_KEY: ${remote_driver_client}
      DRONE_STASH_CONSUMER_RSA_STRING: ${remote_driver_secret}
      DRONE_STASH_URL: ${remote_driver_url}
{{- end}}
{{- if eq .Values.remote_driver "GitLab"}}
      DRONE_GITLAB: true
      DRONE_GITLAB_CLIENT: ${remote_driver_secret}
      DRONE_GITLAB_SECRET: ${remote_driver_secret}
      DRONE_GITLAB_URL: ${remote_driver_url}
{{- end}}
{{- if eq .Values.remote_driver "Gogs"}}
      DRONE_GOGS: true
      DRONE_GOGS_URL: ${remote_driver_url}
{{- end}}
      DRONE_DATABASE_DRIVER: mysql
{{- if (.Values.mysql_host)}}
      DRONE_DATABASE_DATASOURCE: ${mysql_user}:${mysql_password}@tcp(${mysql_host}:3306)/${mysql_database}?parseTime=true
{{- else }}
      DRONE_DATABASE_DATASOURCE: ${mysql_user}:${mysql_password}@tcp(mysql:${mysql_port})/${mysql_database}?parseTime=true
{{- end}}
    labels:
      io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
      io.rancher.container.hostname_override: container_name

{{- if (.Values.mysql_host)}}
  mysql:
    image: mariadb:10.3.7
    environment:
      MYSQL_DATABASE: ${mysql_database}
      MYSQL_USER: ${mysql_user}
      MYSQL_PASSWORD: ${mysql_password}
    volume_driver: ${volume_driver}
    volumes:
      - $${stack_name}--$${service_name}-data:/var/lib/mysql
{{- end}}
