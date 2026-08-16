#!/bin/bash

echo "=========================================="
echo " Linux Authentication Security Analysis"
echo "=========================================="
echo
echo "Analysis Time: $(date)"
echo "Hostname: $(hostname)"
echo

echo "=== FAILED AUTHENTICATION EVENTS ==="
journalctl --since "24 hours ago" --no-pager |
grep -Ei "authentication failure|password check failed|failed password"

echo
echo "=== FAILED AUTHENTICATION COUNT ==="
journalctl --since "24 hours ago" --no-pager |
grep -Eic "authentication failure|password check failed|failed password"

echo
echo "=== PRIVILEGED COMMAND EXECUTION ==="
journalctl --since "24 hours ago" --no-pager |
grep "COMMAND="

echo
echo "=== PRIVILEGED COMMAND COUNT ==="
journalctl --since "24 hours ago" --no-pager |
grep -c "COMMAND="

echo
echo
echo "=== HIGH-INTEREST PRIVILEGED COMMANDS ==="
journalctl --since "24 hours ago" --no-pager |
grep "COMMAND=" |
grep -Ei "nmap|docker|systemctl|apt install|useradd|usermod|passwd|chmod|chown"
HIGH_INTEREST=$(journalctl --since "24 hours ago" --no-pager |
grep "COMMAND=" |
grep -Eic "nmap|docker|systemctl|apt install|useradd|usermod|passwd|chmod|chown")

echo
echo "High-interest privileged commands: $HIGH_INTEREST"
echo "=== SECURITY SUMMARY ==="

FAILED=$(journalctl --since "24 hours ago" --no-pager |
grep -Eic "authentication failure|password check failed|failed password")

PRIV=$(journalctl --since "24 hours ago" --no-pager |
grep -c "COMMAND=")

echo "Failed authentication events: $FAILED"
echo "Privileged command events: $PRIV"
echo "High-interest privileged commands: $HIGH_INTEREST"
if [ "$FAILED" -ge 3 ]; then
    echo "ALERT: Multiple authentication failures detected."
else
    echo "STATUS: Authentication failures below alert threshold."
fi
