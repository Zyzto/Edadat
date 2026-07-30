#!/usr/bin/env bash
# Verify pubspec.yaml version is valid semver and optionally matches a git tag.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBSPEC="$ROOT/pubspec.yaml"

version="$(sed -nE 's/^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)(\+[0-9]+)?/\1/p' "$PUBSPEC" | head -1)"
if [[ -z "$version" ]]; then
  echo "error: could not parse version from pubspec.yaml" >&2
  exit 1
fi

if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "error: version '$version' is not MAJOR.MINOR.PATCH" >&2
  exit 1
fi

echo "pubspec version: $version"

if [[ "${1:-}" == "--expect-tag" ]]; then
  tag="${2:-}"
  if [[ -z "$tag" ]]; then
    echo "usage: $0 --expect-tag vX.Y.Z" >&2
    exit 1
  fi
  expected="${tag#v}"
  if [[ "$version" != "$expected" ]]; then
    echo "error: pubspec version ($version) does not match tag ($tag)" >&2
    exit 1
  fi
  echo "tag $tag matches pubspec"
fi
