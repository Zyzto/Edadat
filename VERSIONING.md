# Versioning & releases

Edadat (`flutter_settings_framework`) uses **[SemVer](https://semver.org/)**:

| Part | When to bump |
|------|----------------|
| **MAJOR** | Breaking API changes |
| **MINOR** | Backward-compatible features |
| **PATCH** | Backward-compatible fixes |

## Tag format

Git tags are `vMAJOR.MINOR.PATCH` (example: `v0.5.0`).

The tag **must** match `version:` in [`pubspec.yaml`](pubspec.yaml) (build metadata `+N` is ignored for tagging).

## Consumer apps (e.g. Hisab)

Pin a **tag**, not `main` or a raw commit:

```yaml
dependencies:
  flutter_settings_framework:
    git:
      url: https://github.com/Zyzto/edadat.git
      ref: v0.5.0
```

## Release checklist

1. Update `version:` in `pubspec.yaml`.
2. Add a `## [X.Y.Z] - YYYY-MM-DD` section to `CHANGELOG.md`.
3. Commit on `main` and push.
4. Run:

```bash
./scripts/release.sh
```

This runs analyze + tests, creates an annotated tag `vX.Y.Z`, and pushes it.  
The **Release** GitHub Action then re-verifies the tag, runs tests, and publishes a GitHub Release.

Dry-run:

```bash
./scripts/release.sh --dry-run
```

## CI

| Workflow | Trigger | What it does |
|----------|---------|----------------|
| [CI](.github/workflows/ci.yml) | push/PR to `main` | version check, `dart analyze`, `flutter test` |
| [Release](.github/workflows/release.yml) | tag `v*.*.*` | tag↔pubspec check, CHANGELOG check, tests, GitHub Release |
