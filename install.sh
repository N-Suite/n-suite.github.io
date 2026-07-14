#!/bin/bash
set -euo pipefail

SERVER_BASE_URL=${SERVER_BASE_URL:-https://n-suite.github.io}
APPLICATION_SUPPORT_DIR=${APPLICATION_SUPPORT_DIR:-"$HOME/Library/Application Support"}

EXTENSION_BUNDLE_ID="dev.n-suite.extension"
EXTENSION_HELPER_BUNDLE_ID="dev.n_suite.extension.helper"

mkdir -p "$APPLICATION_SUPPORT_DIR/Google/Chrome/NativeMessagingHosts/"
cat <<EOF > "$APPLICATION_SUPPORT_DIR/Google/Chrome/NativeMessagingHosts/$EXTENSION_HELPER_BUNDLE_ID.json"
{
  "name": "$EXTENSION_HELPER_BUNDLE_ID",
  "description": "Native Messaging Host for N Extension",
  "path": "$APPLICATION_SUPPORT_DIR/$EXTENSION_BUNDLE_ID/extension-helper-$(uname -m)",
  "type": "stdio",
  "allowed_origins": ["chrome-extension://ajbcfkngjknleogmjkekkajnffgefjem/"]
}
EOF

mkdir -p "$APPLICATION_SUPPORT_DIR/$EXTENSION_BUNDLE_ID/"
curl -sL "$SERVER_BASE_URL/downloads/helper/extension-helper-$(uname -m).gz" | gunzip > "$APPLICATION_SUPPORT_DIR/$EXTENSION_BUNDLE_ID/extension-helper-$(uname -m)"
chmod +x "$APPLICATION_SUPPORT_DIR/$EXTENSION_BUNDLE_ID/extension-helper-$(uname -m)"
xattr -c "$APPLICATION_SUPPORT_DIR/$EXTENSION_BUNDLE_ID/extension-helper-$(uname -m)"

echo '1/2: Extension Helperをインストールしました。'

mkdir -p "$APPLICATION_SUPPORT_DIR/$EXTENSION_BUNDLE_ID/chrome-extension/"
curl -sL "$SERVER_BASE_URL/downloads/extension/chrome-extension.tar.gz" | tar -xzf - -C "$APPLICATION_SUPPORT_DIR/$EXTENSION_BUNDLE_ID/chrome-extension/"

echo '2/2: Chrome用拡張機能をダウンロードしました。'

rm -rf "$HOME/Downloads/n-suite-chrome-extension"
ln -s "$APPLICATION_SUPPORT_DIR/$EXTENSION_BUNDLE_ID/chrome-extension/" "$HOME/Downloads/n-suite-chrome-extension"

echo 'セットアップが完了しました。続きは: https://n-suite.github.io を参照してください。'