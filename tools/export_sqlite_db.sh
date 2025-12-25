#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  tools/export_sqlite_db.sh [--platform auto|ios|android] [--db-name seek_offline.db] [--out-dir db_exports]
                           [--bundle-id <ios_bundle_id>] [--package <android_package>]

Examples:
  # Auto-detect (prefers Android if an adb device is connected, otherwise iOS Simulator)
  tools/export_sqlite_db.sh

  # iOS Simulator
  tools/export_sqlite_db.sh --platform ios

  # Android
  tools/export_sqlite_db.sh --platform android

Notes:
  - This script exports the SQLite file from a running app into your repo.
  - If WAL mode is used, it will also try to export '<db>-wal' and '<db>-shm'.
  - Android export relies on 'run-as', so it requires a debuggable build.
EOF
}

PLATFORM="auto"
DB_NAME="seek_offline.db"
OUT_DIR="db_exports"
BUNDLE_ID=""
ANDROID_PKG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)
      PLATFORM="${2:-}"; shift 2 ;;
    --db-name)
      DB_NAME="${2:-}"; shift 2 ;;
    --out-dir)
      OUT_DIR="${2:-}"; shift 2 ;;
    --bundle-id)
      BUNDLE_ID="${2:-}"; shift 2 ;;
    --package)
      ANDROID_PKG="${2:-}"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown arg: $1" >&2
      usage; exit 2 ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Resolve OUT_DIR to absolute path
if [[ "$OUT_DIR" = /* ]]; then
  OUT_DIR_ABS="$OUT_DIR"
else
  OUT_DIR_ABS="$ROOT_DIR/$OUT_DIR"
fi
mkdir -p "$OUT_DIR_ABS"

now_ts="$(date +"%Y%m%d_%H%M%S")"

infer_ios_bundle_id() {
  local pbxproj="$ROOT_DIR/mobile/ios/Runner.xcodeproj/project.pbxproj"
  if [[ -f "$pbxproj" ]]; then
    grep -m1 'PRODUCT_BUNDLE_IDENTIFIER' "$pbxproj" | sed -E 's/.*= ([^;]+);/\1/' | tr -d ' '
  fi
}

infer_android_package() {
  local gradle="$ROOT_DIR/mobile/android/app/build.gradle.kts"
  if [[ -f "$gradle" ]]; then
    grep -m1 'applicationId\s*=' "$gradle" | sed -E 's/.*"([^"]+)".*/\1/' | tr -d ' '
  fi
}

has_adb_device() {
  command -v adb >/dev/null 2>&1 || return 1
  adb devices 2>/dev/null | awk 'NR>1 && $2=="device" {print $1; exit 0} END {exit 1}' >/dev/null 2>&1
}

has_booted_ios_sim() {
  command -v xcrun >/dev/null 2>&1 || return 1
  xcrun simctl list devices booted 2>/dev/null | grep -Eo '[0-9A-F-]{36}' | head -n 1 | grep -q .
}

export_ios_sim() {
  local bundle_id="$1"
  if [[ -z "$bundle_id" ]]; then
    echo "iOS bundle id is empty. Provide --bundle-id or ensure ios/Runner.xcodeproj exists." >&2
    exit 1
  fi

  local udid
  udid="$(xcrun simctl list devices booted | grep -Eo '[0-9A-F-]{36}' | head -n 1)"
  if [[ -z "$udid" ]]; then
    echo "No booted iOS Simulator found. Boot a simulator and run the app." >&2
    exit 1
  fi

  local container
  if ! container="$(xcrun simctl get_app_container "$udid" "$bundle_id" data 2>/dev/null)"; then
    echo "Failed to locate app container. Is the app installed on the booted simulator? (bundleId=$bundle_id)" >&2
    exit 1
  fi

  local db_path
  db_path="$(find "$container" -type f -name "$DB_NAME" 2>/dev/null | head -n 1)"
  if [[ -z "$db_path" ]]; then
    echo "DB file '$DB_NAME' not found under container: $container" >&2
    echo "Tip: confirm your DB name and that the app has created/opened it (sqflite getDatabasesPath)." >&2
    exit 1
  fi

  local out_base="$OUT_DIR_ABS/${bundle_id}_iossim_${now_ts}"
  mkdir -p "$out_base"

  cp -f "$db_path" "$out_base/$DB_NAME"
  [[ -f "${db_path}-wal" ]] && cp -f "${db_path}-wal" "$out_base/${DB_NAME}-wal" || true
  [[ -f "${db_path}-shm" ]] && cp -f "${db_path}-shm" "$out_base/${DB_NAME}-shm" || true

  echo "Exported: $out_base/$DB_NAME"
  [[ -f "$out_base/${DB_NAME}-wal" ]] && echo "Exported: $out_base/${DB_NAME}-wal" || true
  [[ -f "$out_base/${DB_NAME}-shm" ]] && echo "Exported: $out_base/${DB_NAME}-shm" || true
}

export_android() {
  local pkg="$1"
  if [[ -z "$pkg" ]]; then
    echo "Android package is empty. Provide --package or ensure android/app/build.gradle.kts exists." >&2
    exit 1
  fi

  if ! command -v adb >/dev/null 2>&1; then
    echo "adb not found. Install Android platform-tools." >&2
    exit 1
  fi

  local device
  device="$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit 0}')"
  if [[ -z "$device" ]]; then
    echo "No Android device/emulator found via adb." >&2
    exit 1
  fi

  if ! adb -s "$device" shell run-as "$pkg" id >/dev/null 2>&1; then
    echo "adb run-as failed for package '$pkg'." >&2
    echo "This usually means the app is not debuggable (use a debug build), or the package name is wrong." >&2
    exit 1
  fi

  local rel_path
  rel_path="$(adb -s "$device" shell run-as "$pkg" sh -c "if [ -f databases/$DB_NAME ]; then echo databases/$DB_NAME; else find . -type f -name '$DB_NAME' 2>/dev/null | head -n 1; fi" | tr -d '\r')"
  if [[ -z "$rel_path" ]]; then
    echo "DB file '$DB_NAME' not found inside app sandbox (package=$pkg)." >&2
    exit 1
  fi

  local out_base="$OUT_DIR_ABS/${pkg}_android_${now_ts}"
  mkdir -p "$out_base"

  adb -s "$device" exec-out run-as "$pkg" cat "$rel_path" > "$out_base/$DB_NAME"

  # Try exporting WAL/SHM if present
  local wal_path="${rel_path}-wal"
  local shm_path="${rel_path}-shm"

  if adb -s "$device" shell run-as "$pkg" sh -c "test -f '$wal_path'" >/dev/null 2>&1; then
    adb -s "$device" exec-out run-as "$pkg" cat "$wal_path" > "$out_base/${DB_NAME}-wal"
  fi
  if adb -s "$device" shell run-as "$pkg" sh -c "test -f '$shm_path'" >/dev/null 2>&1; then
    adb -s "$device" exec-out run-as "$pkg" cat "$shm_path" > "$out_base/${DB_NAME}-shm"
  fi

  echo "Exported: $out_base/$DB_NAME"
  [[ -f "$out_base/${DB_NAME}-wal" ]] && echo "Exported: $out_base/${DB_NAME}-wal" || true
  [[ -f "$out_base/${DB_NAME}-shm" ]] && echo "Exported: $out_base/${DB_NAME}-shm" || true
}

case "$PLATFORM" in
  auto)
    if has_adb_device; then
      PLATFORM="android"
    elif has_booted_ios_sim; then
      PLATFORM="ios"
    else
      echo "Auto-detect failed: no adb device and no booted iOS Simulator." >&2
      echo "Use: --platform ios|android" >&2
      exit 1
    fi
    ;;
  ios|android)
    ;;
  *)
    echo "Invalid --platform: $PLATFORM (expected auto|ios|android)" >&2
    exit 2
    ;;
esac

if [[ "$PLATFORM" == "ios" ]]; then
  [[ -z "$BUNDLE_ID" ]] && BUNDLE_ID="$(infer_ios_bundle_id || true)"
  export_ios_sim "$BUNDLE_ID"
else
  [[ -z "$ANDROID_PKG" ]] && ANDROID_PKG="$(infer_android_package || true)"
  export_android "$ANDROID_PKG"
fi
