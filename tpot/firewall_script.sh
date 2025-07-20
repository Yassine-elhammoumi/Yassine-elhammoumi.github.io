#!/bin/bash

# List of expected incoming ports (format: port/protocol)
INCOMING_PORTS=(
  "64294/tcp" "64295/tcp" "64297/tcp" "5555/tcp" "22/tcp" "5000/udp" "8443/tcp"
  "443/tcp" "80/tcp" "102/tcp" "502/tcp" "1025/tcp" "2404/tcp" "10001/tcp"
  "44818/tcp" "47808/tcp" "50100/tcp" "161/udp" "623/udp" "19/udp" "53/udp"
  "123/udp" "1900/udp" "11112/tcp" "21/tcp" "42/tcp" "135/tcp" "445/tcp"
  "1433/tcp" "1723/tcp" "1883/tcp" "3306/tcp" "8081/tcp" "9200/tcp" "8080/tcp"
  "3000/tcp" "1521/tcp" "3389/tcp" "5060/tcp" "5432/tcp" "5900/tcp" "6379/tcp"
  "6667/tcp" "9100/tcp" "11211/tcp" "631/tcp" "25565/tcp" "25/tcp" "2575/tcp"
  "8090/tcp" "110/tcp" "143/tcp" "993/tcp" "995/tcp" "1080/tcp" "389/tcp" "11434/tcp" "23/tcp" "69/udp" "5060/udp"
)

# Retrieve the current list of allowed ports from firewalld
CURRENT_PORTS=$(sudo firewall-cmd --list-ports)

echo "Checking ports..."
echo

# Track missing and unexpected ports
MISSING=0
UNEXPECTED=0

# Convert the list to a set for easier lookup
declare -A EXPECTED_SET
for port in "${INCOMING_PORTS[@]}"; do
  EXPECTED_SET["$port"]=1
done

# Check for missing ports
for port in "${INCOMING_PORTS[@]}"; do
  if echo "$CURRENT_PORTS" | grep -qw "$port"; then
    echo "$port is open"
  else
    echo "$port is MISSING"
    ((MISSING++))
  fi
done

echo
echo "Checking for unexpected open ports..."
echo

# Check for unexpected open ports
for open in $CURRENT_PORTS; do
  if [[ -z "${EXPECTED_SET[$open]}" ]]; then
    echo "$open is UNEXPECTED"
    ((UNEXPECTED++))
  fi
done

# Summary
echo
echo "Summary:"
echo "Missing ports: $MISSING"
echo "Unexpected ports: $UNEXPECTED"

if [[ "$MISSING" -eq 0 && "$UNEXPECTED" -eq 0 ]]; then
  echo "All ports are correctly configured."
else
  echo "Please check the configuration. Use 'firewall-cmd --remove-port=PORT' to remove unexpected entries."
fi
