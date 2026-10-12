#!/bin/sh
set -eu

mkdir -p /opt/apito/keys /data /usr/share/nginx/html
if [ ! -f /opt/apito/keys/private.key ]; then
  openssl genrsa -out /opt/apito/keys/private.key 2048
  openssl rsa -in /opt/apito/keys/private.key -pubout -out /opt/apito/keys/public.key
fi

cat > /usr/share/nginx/html/env.js <<'EOF'
window.env = {
  VITE_REST_API: window.location.origin,
  VITE_GRAPH_API: window.location.origin + "/system/graphql",
  VITE_PUBLIC_GRAPH_API: window.location.origin + "/system/graphql",
  VITE_GRAPH_SUBS_API: window.location.origin.replace(/^http/, "ws") + "/system/graphql/subscription",
  VITE_AUTH_PROVIDER: "local",
  VITE_COOKIE_DOMAIN: window.location.hostname
};
EOF

cd /opt/apito
./engine &
exec nginx -g 'daemon off;'
