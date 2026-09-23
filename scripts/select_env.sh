#!/usr/bin/env bash
# Copies .env.<environment> to .env — the single file pubspec.yaml declares
# as a Flutter asset. Run this before `flutter run`/`flutter build` with a
# matching --dart-define=APP_ENV=<environment>, so the bundled .env and the
# dart-define agree. Only ONE environment's values are ever in .env at a
# time — this is what keeps dev/staging/prod credentials from all shipping
# into every build. See README.md "Development Setup" and
# docs/audit-findings.md (FT-001).
#
# Usage: scripts/select_env.sh [development|staging|production]
#   (defaults to development, matching the app's own default)

set -euo pipefail

ENV_NAME="${1:-development}"

case "$ENV_NAME" in
  development|staging|production) ;;
  *)
    echo "error: unknown environment '$ENV_NAME' (expected development, staging, or production)" >&2
    exit 1
    ;;
esac

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_ROOT/.env.$ENV_NAME"
DEST="$REPO_ROOT/.env"

if [ ! -f "$SRC" ]; then
  echo "error: $SRC does not exist." >&2
  echo "Create it first, e.g.: cp .env.$ENV_NAME.example .env.$ENV_NAME" >&2
  exit 1
fi

cp "$SRC" "$DEST"
echo "Copied .env.$ENV_NAME -> .env"
