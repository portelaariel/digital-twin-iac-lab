#!/bin/bash

echo "======================================"
echo " Medindo ambiente REAL"
echo "======================================"

RESULT=$(docker exec client-real \
  ping -c 50 -i 0.1 172.20.0.20)

echo "$RESULT"

LOSS=$(echo "$RESULT" |
  awk -F', ' '/packet loss/ {
    gsub("% packet loss", "", $3)
    print $3
  }')

AVG=$(echo "$RESULT" |
  awk -F' = ' '/min\/avg\/max/ {
    split($2,a,"/")
    print a[2]
  }')

echo ""
echo "======================================"
echo " Métricas coletadas"
echo "======================================"

echo "Latência média: ${AVG} ms"
echo "Perda: ${LOSS}%"

cat > real_metrics.env <<EOF
DELAY_MS=$AVG
LOSS_PERCENT=$LOSS
EOF

echo ""
echo "Arquivo real_metrics.env atualizado."