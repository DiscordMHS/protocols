#!/usr/bin/env bash
set -euo pipefail

OPENAPI_DIR="/usr/share/nginx/html/openAPI"

if [ ! -d "$OPENAPI_DIR" ]; then
  echo "[WARN] Directory $OPENAPI_DIR does not exist. No OpenAPI specs found."
fi

###############################################################################
# Apply host overrides to swagger files
###############################################################################

patch_swagger_file() {
  local file="$1"
  local service="$2"

  local env_var="$(echo "${service}_HOST" | tr '[:lower:]' '[:upper:]')"
  local host_value="${!env_var:-}"

  if [ -z "$host_value" ]; then
    echo "[INFO] No host override for $service ($env_var is not set)"
    return
  fi

  echo "[INFO] Applying host override for $service → $host_value"

  local scheme="http"
  local host="$host_value"
  local base_path=""

  # Extract scheme, host, base path
  if [[ "$host_value" =~ ^https:// ]]; then
    scheme="https"
    host="${host_value#https://}"
  elif [[ "$host_value" =~ ^http:// ]]; then
    scheme="http"
    host="${host_value#http://}"
  fi

  if [[ "$host" == */* ]]; then
    base_path="/${host#*/}"
    host="${host%%/*}"
  fi

  jq ".schemes = [\"$scheme\"]" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  jq ".host = \"$host\"" "$file" > "$file.tmp" && mv "$file.tmp" "$file"

  if [ -n "$base_path" ]; then
    jq ".basePath = \"$base_path\"" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  fi

  local full="$scheme://$host$base_path"
  jq ".servers = [{\"url\": \"$full\"}]" "$file" > "$file.tmp" && mv "$file.tmp" "$file"

  echo "[INFO] Patched: host=$host scheme=$scheme basePath=${base_path:-/} url=$full"
}

###############################################################################
# Build Swagger UI URLS array
###############################################################################

URLS="["

add_swagger_file() {
  local file="$1"

  # relative path under /openAPI
  local rel="${file#$OPENAPI_DIR/}"
  IFS="/" read -r service version filename <<< "$rel"

  if [ -z "$service" ] || [ -z "$version" ]; then
    echo "[WARN] Invalid file structure: $rel"
    return
  fi

  local name="$service $version"

  patch_swagger_file "$file" "$service"

  [[ "$URLS" != "[" ]] && URLS+=", "
  URLS+="{ url: \"/openAPI/$rel\", name: \"$name\" }"
}

###############################################################################
# Walk directories and process swagger files
###############################################################################

while IFS= read -r -d '' file; do
  add_swagger_file "$file"
done < <(find "$OPENAPI_DIR" -type f -name "*.json" -print0)

URLS+="]"

export URLS
echo "[INFO] Swagger UI will load: $URLS"
echo ""

###############################################################################
# Start nginx
###############################################################################
exec /docker-entrypoint.sh "$@"
