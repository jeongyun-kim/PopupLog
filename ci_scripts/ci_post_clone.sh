#!/bin/sh

set -e

echo "🔧 Creating Secrets.xcconfig..."

# 절대경로로 생성
XCCONFIG_PATH="/Volumes/workspace/repository/Secrets.xcconfig"

cat > "$XCCONFIG_PATH" << EOF
N_CLIENT = ${N_CLIENT}
N_SECRET = ${N_SECRET}
BASE_URL = ${BASE_URL}
API_KEY = ${API_KEY}
CLIENT_ID = ${CLIENT_ID}
EOF

echo "✅ Created: $XCCONFIG_PATH"
ls -la "$XCCONFIG_PATH"
