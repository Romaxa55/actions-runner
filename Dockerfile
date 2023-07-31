ARG RUNNER_VERSION=2.307.1

# hadolint ignore=DL3007
FROM ubuntu:23.10 as base
LABEL maintainer="Roman Shamagin"

# Создаем рабочую директорию
WORKDIR /actions-runner

RUN apt-get update -q && \
    apt-get install -yq --no-install-recommends curl ca-certificates docker.io && \
    rm -rf /var/lib/apt/lists/*

ARG RUNNER_VERSION
ENV RUNNER_ALLOW_RUNASROOT=true
# Определяем архитектуру системы
RUN set -x && \
    export RUNNER_ARCH="$(uname -m)" && \
    case ${RUNNER_ARCH} in \
      x86_64) RUNNER_ARCH="x64" ;; \
      aarch64) RUNNER_ARCH="arm64" ;; \
      *) echo "Unsupported architecture" && exit 1 ;; \
    esac && \
    curl -o actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz && \
    rm ./actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz

# Устанавливаем зависимости
RUN ./bin/installdependencies.sh && \
    rm -rf /var/lib/apt/lists/*

# Копируем файл entrypoint.sh в контейнер
COPY entrypoint.sh /entrypoint.sh

# Устанавливаем файл entrypoint.sh в качестве точки входа
ENTRYPOINT ["/entrypoint.sh"]

# Запускаем раннер
CMD ["./run.sh"]