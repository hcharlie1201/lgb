#!/bin/zsh

# Read .env file and set Fly secrets
while read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^\s*# ]] && continue

    # Remove 'export ' prefix and split into key and value
    key=$(echo "$line" | sed 's/^export //' | cut -d'=' -f1)
    value=$(echo "$line" | sed 's/^export //' | cut -d'=' -f2-)

    echo "Setting secret: $key"
    fly secrets set "$key"="$value"
done < .env.prod

echo "All secrets set successfully!"
