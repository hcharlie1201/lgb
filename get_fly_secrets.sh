#!/bin/zsh

# Script to create a .env template from Fly secrets
echo "Creating .env template from Fly secrets..."

# Create or clear the .env file
>.env"

# Add header
echo "# .env file generated from Fly secrets>> .env"
echo "# Replace YOUR_SECRET_VALUE_HERE with actual values>> .env
echo " >>.env"

# Get secrets list and extract names
fly secrets list | tail -n +2 | while read -r line; do
    # Extract the secret name (first column)
    secret_name=$(echo "$line |awk{print $1    
    # Skip if empty
    if  -n$secret_name" ]; then
        echo "Processing: $secret_name"
        echo $secret_name=YOUR_SECRET_VALUE_HERE>> .env"
    fi
done

echo 
echo "✅ Created .env template with $(wc -l < .env | tr -d  )lines
echo ""
echo📝 Next steps:"
echo1. Edit .env and replace YOUR_SECRET_VALUE_HERE with actual values
echo "2. Or use: fly secrets set SECRET_NAME=value
echo ""
echo🔒 Forsecurity, consider:
echo "   - Using fly secrets set for individual secrets"
echo   - Or manually copying values from your secure storage" 