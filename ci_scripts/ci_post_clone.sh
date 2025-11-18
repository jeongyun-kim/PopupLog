#!/bin/sh

set -e

echo "🔧 Creating Secrets.xcconfig..."

cat > ./Secrets.xcconfig << EOF
N_CLIENT = ${N_CLIENT}
N_SECRET = ${N_SECRET}
BASE_URL = ${BASE_URL}
API_KEY = ${API_KEY}
CLIENT_ID = ${CLIENT_ID}
EOF

echo "✅ Secrets.xcconfig created"

if [ -f ./Secrets.xcconfig ]; then
    echo "✅ File verified"
else
    echo "❌ File not found!"
    exit 1
fi
