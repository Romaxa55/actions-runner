#!/bin/sh

# Проверяем наличие обязательных переменных окружения
if [ -z "$RUNNER_URL" ] || [ -z "$RUNNER_TOKEN" ]; then
  echo "ОШИБКА: Переменные RUNNER_URL и RUNNER_TOKEN должны быть установлены."
  exit 1
fi

# Определяем архитектуру
RUNNER_ARCH="$(uname -m)"
case ${RUNNER_ARCH} in
  x86_64) RUNNER_ARCH="amd64" ;;
  aarch64) RUNNER_ARCH="arm64" ;;
  *) echo "Неподдерживаемая архитектура" && exit 1 ;;
esac

# Устанавливаем имя и метки в зависимости от архитектуры
RUNNER_NAME="${RUNNER_ARCH}"
RUNNER_LABELS="linux,${RUNNER_ARCH}"

./config.sh \
  --url ${RUNNER_URL} \
  --token ${RUNNER_TOKEN} \
  --labels ${RUNNER_LABELS} \
  --name ${RUNNER_NAME} \
  --work build \
  --runnergroup default

exec "$@"
