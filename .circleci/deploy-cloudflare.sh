#!/usr/bin/env bash

apt install -y npm
npm install -g wrangler

cat <<EOF > "build/html/wrangler.toml"
name = "unborn"
workers_dev = false
EOF

npx wrangler pages publish build/html
