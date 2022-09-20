#!/usr/bin/env bash

apt update
apt -y install curl

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts

npx wrangler pages publish --branch=publish build/html --project-name "unborn"
