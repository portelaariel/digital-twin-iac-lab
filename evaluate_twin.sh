#!/bin/bash

PRIMARY="172.21.0.20"
BACKUP="172.21.0.21"

echo "======================================"
echo " Digital Twin - Failure Test"
echo "======================================"

echo ""
echo "Simulando falha do servidor principal..."

docker stop server-twin >/dev/null

sleep 1

echo ""
echo "Testando servidor principal..."

if docker exec client-twin \
    ping -c 2 -W 1 "$PRIMARY" >/dev/null 2>&1
then
    echo "PRIMARY: AVAILABLE"
else
    echo "PRIMARY: DOWN"
fi

echo ""
echo "Procurando servidor backup..."

BACKUP_OK=false

if docker ps --format '{{.Names}}' |
   grep -qx "server-twin-backup"
then

    if docker exec client-twin \
       ping -c 3 -W 1 "$BACKUP" >/dev/null 2>&1
    then
        echo "BACKUP: AVAILABLE"
        BACKUP_OK=true
    else
        echo "BACKUP: UNREACHABLE"
    fi

else
    echo "BACKUP: NOT DEPLOYED"
fi

echo ""
echo "Restaurando servidor principal..."

docker start server-twin >/dev/null

echo ""
echo "======================================"
echo " RESULT"
echo "======================================"

if [ "$BACKUP_OK" = true ]; then
    echo "PASS: infrastructure survived primary failure."
    exit 0
else
    echo "FAIL: primary failure caused loss of availability."
    exit 2
fi