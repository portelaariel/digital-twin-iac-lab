#!/bin/bash

echo "======================================"
echo " Digital Twin Decision Engine"
echo "======================================"

echo ""

./evaluate_twin.sh

RESULT=$?

echo ""

if [ "$RESULT" -eq 0 ]; then

    echo "Digital Twin passed the resilience test."
    echo "No infrastructure change required."

else

    echo "Digital Twin failed."
    echo ""
    echo "Decision:"
    echo "Deploy backup server in Digital Twin."

    cat > decision.auto.tfvars <<EOF
enable_backup_twin = true
enable_backup_real = false
EOF

    echo ""
    echo "Terraform configuration updated:"
    cat decision.auto.tfvars

fi