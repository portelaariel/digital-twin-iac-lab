#!/bin/bash

if [ ! -f real_metrics.env ]; then
    echo "Erro: real_metrics.env não encontrado."
    echo "Execute ./measure_real.sh primeiro."
    exit 1
fi

source real_metrics.env

echo "======================================"
echo " Sincronizando Digital Twin"
echo "======================================"

echo "Delay: ${DELAY_MS} ms"
echo "Loss: ${LOSS_PERCENT}%"

docker exec client-twin \
  tc qdisc replace dev eth0 root netem \
  delay "${DELAY_MS}ms" \
  loss "${LOSS_PERCENT}%"

echo ""
echo "Digital Twin atualizado."

echo ""
docker exec client-twin tc qdisc show dev eth0