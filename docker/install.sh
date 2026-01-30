#!/bin/sh
#
# Docker config setup - platform aware

# Detect platform and set appropriate credsStore
if [ "$(uname -s)" = "Darwin" ]; then
  # macOS - include credsStore
  cat > ~/.docker/config.json << EOF
{
	"auths": {
		"ghcr.io": {}
	},
	"credsStore": "osxkeychain",
	"currentContext": "colima-mac",
	"aliases": {
		"builder": "buildx"
	}
}
EOF
else
  # Linux - omit credsStore to avoid credential helper errors
  cat > ~/.docker/config.json << EOF
{
	"auths": {
		"ghcr.io": {}
	},
	"currentContext": "colima-mac",
	"aliases": {
		"builder": "buildx"
	}
}
EOF
fi

echo "  Generated Docker config for $(uname -s)"

exit 0
