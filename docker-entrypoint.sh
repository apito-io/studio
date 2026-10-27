#!/bin/sh
set -eu

if [ ! -s /opt/apito/.env ]; then
  echo "Studio is missing /opt/apito/.env. Run apito start so it can write ~/.apito/bin/.env.engine and mount it." >&2
  exit 1
fi
if [ ! -s /opt/apito/.env.console ]; then
  echo "Studio is missing /opt/apito/.env.console. Run apito start so it can write ~/.apito/bin/.env.console and mount it." >&2
  exit 1
fi

mkdir -p /data/keys /data/plugins /data/logs /data/sqlite/system /data/sqlite/projects /data/sqlite/tenants /usr/share/nginx/html

env_value() {
  awk -F= -v key="$1" '
    $0 ~ "^" key "=" {
      val = substr($0, index($0, "=") + 1)
      gsub(/^"/, "", val)
      gsub(/"$/, "", val)
      print val
      exit
    }
  ' /opt/apito/.env
}

priv="$(env_value PRIVATE_KEY_PATH)"
pub="$(env_value PUBLIC_KEY_PATH)"
if [ -n "$priv" ] && [ ! -f "$priv" ]; then
  mkdir -p "$(dirname "$priv")"
  openssl genrsa -out "$priv" 2048
  if [ -z "$pub" ]; then
    pub="$(dirname "$priv")/public.key"
  fi
  mkdir -p "$(dirname "$pub")"
  openssl rsa -in "$priv" -pubout -out "$pub"
fi

awk '
BEGIN { print "window.env = {" }
/^[[:space:]]*($|#)/ { next }
{
  eq = index($0, "=")
  if (eq == 0) next
  key = substr($0, 1, eq - 1)
  val = substr($0, eq + 1)
  gsub(/^"/, "", val)
  gsub(/"$/, "", val)
  gsub(/\\/, "\\\\", val)
  gsub(/"/, "\\\"", val)
  printf "  %s: \"%s\",\n", key, val
}
END { print "};" }
' /opt/apito/.env.console > /usr/share/nginx/html/env.js

cd /opt/apito
./engine &
engine_pid=$!
nginx -g 'daemon off;' &
nginx_pid=$!

while kill -0 "$engine_pid" 2>/dev/null && kill -0 "$nginx_pid" 2>/dev/null; do
  sleep 1
done

if ! kill -0 "$engine_pid" 2>/dev/null; then
  echo "engine exited" >&2
  kill "$nginx_pid" 2>/dev/null || true
  wait "$engine_pid" 2>/dev/null || true
  exit 1
fi

kill "$engine_pid" 2>/dev/null || true
wait "$nginx_pid" 2>/dev/null || exit 1
