#!/bin/bash

echo ""
echo "======================================"
echo " REAL - PING"
echo "======================================"

docker exec client-real \
ping -c 20 172.20.0.20

echo ""
echo "======================================"
echo " TWIN - PING"
echo "======================================"

docker exec client-twin \
ping -c 20 172.21.0.20


echo ""
echo "======================================"
echo " REAL - IPERF TCP"
echo "======================================"

docker exec client-real \
iperf3 -c 172.20.0.20 -t 10


echo ""
echo "======================================"
echo " TWIN - IPERF TCP"
echo "======================================"

docker exec client-twin \
iperf3 -c 172.21.0.20 -t 10


echo ""
echo "======================================"
echo " REAL - IPERF UDP"
echo "======================================"

docker exec client-real \
iperf3 -c 172.20.0.20 \
-u -b 10M -t 10


echo ""
echo "======================================"
echo " TWIN - IPERF UDP"
echo "======================================"

docker exec client-twin \
iperf3 -c 172.21.0.20 \
-u -b 10M -t 10